# Sinatra Flash

Simple flash hash implementation for Sinatra.

## Usage

    class MyApp < Sinatra::Base
      include Sinatra::Flash

      get '/' do
        flash[:greeting] || "No greeting..."
      end

      get '/greeting' do
        flash[:greeting] = params[:q]
        redirect '/'
      end

      run!
    end

Run the app. Nothing on the home page by default. Then go here:

    /greeting?q=it-works!

You'll see the flash message. Hit refresh, it'll be gone. As it should be.
