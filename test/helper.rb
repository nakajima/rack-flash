require 'rubygems'
gem 'sinatra', '<=1.3.2'
require 'sinatra/base'
require 'bacon'
require 'rack/test'
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