module Rack
  class Flash
    class SessionUnavailable < StandardError; end
    
    # Implements bracket accessors for storing and retrieving flash entries.
    class FlashHash
      attr_reader :flagged
      
      def initialize(store)
        @store = store
        @store[:__FLASH__] ||= {}
      end

      # Remove an entry from the session and return its value. Cache result in
      # the instance cache.
      def [](key)
        get(key.to_sym)
      end

      # Store the entry in the session, updating the instance cache as well.
      def []=(key,val)
        set(key.to_sym, val)
      end
      
      # Checks for the presence of a flash entry without retrieving or removing
      # it from the cache or store.
      def has?(key)
        [cache, values].any? { |store| store.keys.include?(key.to_sym) }
      end

      # Hide the underlying :__FLASH__ session key and only expose values stored
      # in the flash.
      def inspect
        '#<FlashHash @values=%s>' % [values.inspect]
      end
      
      def to_s
        values.inspect
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

      private
      
      def get(key)
        raise ArgumentError.new("Flash key must be symbol.") unless key.is_a?(Symbol)
        cache[key] ||= values.delete(key)
      end
      
      def set(key, val)
        raise ArgumentError.new("Flash key must be symbol.") unless key.is_a?(Symbol)
        cache[key] = values[key] = val
      end

      # Maintain an instance-level cache of retrieved flash entries. These entries
      # will have been removed from the session, but are still available through
      # the cache.
      def cache
        @cache ||= {}
      end

      # Helper to access flash entries from :__FLASH__ session value. This key
      # is used to prevent collisions with other user-defined session values.
      def values
        @store[:__FLASH__]
      end
    end
    
    def initialize(app)
      @app = app
      @app.class.class_eval do
        def flash
          raise Rack::Flash::SessionUnavailable \
            .new('You must have sessions enabled to use Rack::Flash.') unless env['rack.session']
          @flash ||= Rack::Flash::FlashHash.new(env['rack.session'])
        end
      end
    end
    
    def call(env)
      @app.call(env)
    end
  end
end