module Sinatra
  module Flash
    # Implements bracket accessors for storing and retrieving flash entries.
    class FlashHash
      def initialize(env)
        @session = env['rack.session']
        @session[:__FLASH__] ||= {}
      end

      # Remove an entry from the session and return its value. Cache result in
      # the instance cache.
      def [](key)
        cache[key] ||= values.delete(key)
      end

      # Store the entry in the session, updating the instance cache as well.
      def []=(key,val)
        cache[key] = values[key] = val
      end

      # Hide the underlying :__FLASH__ session key and only expose values stored
      # in the flash.
      def inspect
        '#<FlashHash @values=%s>' % [values.inspect]
      end

      private

      # Maintain an instance-level cache of retrieved flash entries. These entries
      # will have been removed from the session, but are still available through
      # the cache.
      def cache
        @cache ||= {}
      end

      # Helper to access flash entries from :__FLASH__ session value. This key
      # is used to prevent collisions with other user-defined session values.
      def values
        @session[:__FLASH__]
      end
    end

    def flash
      @flash ||= Sinatra::Flash::FlashHash.new(env)
    end
  end
end