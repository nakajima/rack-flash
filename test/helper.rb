require 'rubygems'
require 'sinatra/base'
require 'bacon'
require 'sinatra/test'
require 'sinatra/test/bacon'
require File.join(File.dirname(__FILE__), *%w[.. lib rack flash])

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