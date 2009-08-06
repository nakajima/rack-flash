module Rack
  class Flash
    def self.fake_session
      @fake_session ||= {}
    end
    
    alias_method :old_call, :call
    def new_call(env)
      env['rack.session'] ||= Rack::Flash.fake_session
      old_call(env)
    end
    alias_method :call, :new_call
  end
end