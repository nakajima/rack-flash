require 'rubygems'
require 'sinatra/base'
require File.join(File.dirname(__FILE__), *%w[.. lib sinatra-flash.rb])

class MyApp < Sinatra::Base
  include Sinatra::Flash

  set :root, File.dirname(__FILE__)
  set :layout, true
  set :logging, true
  set :sessions, true
  
  before do
    puts session.inspect
  end
  
  get '/' do
    erb :index
  end
  
  # View the value of any given flash
  get '/:name' do
    erb :show
  end
  
  post '/:name' do
    if params[:message].strip.empty?
      flash["err"] = "You must enter a message."
      flash["err_on_#{params[:name]}"] = 1
      redirect('/')
    end
    
    flash[:ok] = "Set flash entry!"
    
    flash[params[:name]] = params[:message]
    redirect '/'
  end
  
  run!
end