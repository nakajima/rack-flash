require File.dirname(__FILE__) + '/helper'

describe 'Sinatra::Flash' do
  before do
    mock_app {
      include Sinatra::Flash
      
      set :sessions, false
      
      get '/view' do
        flash[:notice]
      end
      
      post '/set' do
        flash[:notice] = params[:q]
        redirect '/view'
      end
    }
  end
  
  it 'is empty by default' do
    err_explain do
      get '/view'
      body.should.be.empty
    end
  end
  
  # Testing sessions is a royal pain in the ass.
end