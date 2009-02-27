require 'rubygems'
require 'sinatra/base'
require 'bacon'
require 'sinatra/test'
require 'sinatra/test/bacon'
require File.join(File.dirname(__FILE__), *%w[.. lib rack-flash])

class String
  [:green, :yellow, :red].each { |c| define_method(c) { self } }
end if ENV['TM_RUBY']

# bacon swallows errors alive
def err_explain
  begin
    yield
  rescue => e
    puts e.inspect
    puts e.backtrace
    raise e
  end
end

def mock_app(&block)
  @app = Sinatra.new(&block)
end

module Rack
  class FakeFlash < Rack::Flash::FlashHash
    attr_reader :flagged, :sweeped, :store

    def initialize(*args)
      @flagged, @sweeped = false, false
      @store = {}
      super(@store)
    end

    def flag!
      @flagged = true
      super
    end

    def sweep!
      @sweeped = true
      super
    end

    def flagged?
      @flagged
    end

    def swept?
      @sweeped
    end
  end
end
