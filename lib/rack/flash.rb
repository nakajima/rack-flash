require 'metaid'

module Rack
  class Flash
    # Raised when the session passed to FlashHash initialize is nil. This
    # is usually an indicator that session middleware is not in use.
    class SessionUnavailable < StandardError; end
    
    # Implements bracket accessors for storing and retrieving flash entries.
    class FlashHash
      attr_reader :flagged
      
      def initialize(store, opts={})
        raise Rack::Flash::SessionUnavailable \
          .new('Rack::Flash depends on session middleware.') unless store
        
        @opts = opts
        @store = store
        @store[:__FLASH__] ||= {}
      end

      # Remove an entry from the session and return its value. Cache result in
      # the instance cache.
      def [](key)
        key = key.to_sym
        cache[key] ||= values.delete(key)
      end

      # Store the entry in the session, updating the instance cache as well.
      def []=(key,val)
        key = key.to_sym
        cache[key] = values[key] = val
      end
      
      # Checks for the presence of a flash entry without retrieving or removing
      # it from the cache or store.
      def has?(key)
        [cache, values].any? { |store| store.keys.include?(key.to_sym) }
      end

      # Mark existing entries to allow for sweeping.
      def flag!
        @flagged = values.keys
      end
      
      # Remove flagged entries from flash session, clear flagged list.
      def sweep!
        Array(flagged).each { |key| values.delete(key) }
        flagged.clear
      end
      
      # Hide the underlying :__FLASH__ session key and only expose values stored
      # in the flash.
      def inspect
        '#<FlashHash @values=%s>' % [values.inspect]
      end
      
      # Human readable for logging.
      def to_s
        values.inspect
      end
      
      # Allow more convenient style for accessing flash entries (This isn't really
      # necessary for Sinatra, since it provides the flash[:foo] hash that we're all
      # used to. This is for vanilla Rack apps where it can be difficult to define
      # such helpers as middleware).
      def method_missing(sym, *args)
        super unless @opts[:accessorize]
        key = sym.to_s =~ /\w=$/ ? sym.to_s[0..-2] : sym
        def_accessors(key)
        send(sym, *args)
      end

      private
      
      # Maintain an instance-level cache of retrieved flash entries. These
      # entries will have been removed from the session, but are still available
      # through the cache.
      def cache
        @cache ||= {}
      end

      # Helper to access flash entries from :__FLASH__ session value. This key
      # is used to prevent collisions with other user-defined session values.
      def values
        @store[:__FLASH__]
      end
      
      # Generate accessor methods for the given entry key if :accessorize is true.
      def def_accessors(key)
        return if respond_to?(key)
        
        meta_def(key) do
          self[key]
        end
        
        meta_def("#{key}=") do |val|
          self[key] = val
        end
      end
    end

    # -------------------------------------------------------------------------
    # - Rack Middleware implementation
    
    def initialize(app, opts={})
      if defined?(Sinatra::Base)
        Sinatra::Base.class_eval do
          def flash; env['rack-flash'] end
        end
      end
      
      @app, @opts = app, opts
    end

    def call(env)
      env['rack-flash'] = Rack::Flash::FlashHash.new(env['rack.session'], @opts)
      @app.call(env)
    end
  end
end