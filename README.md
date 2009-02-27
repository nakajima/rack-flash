# Rack Flash

Simple flash hash implementation for Raçk apps. My implementation has slightly
different behavior than Rails in that it doesn't delete entries until they used.
I think it's pretty rad, but I'm happy to hear thoughts to the contrary.

Try it out here: [flash.patnakajima.net](http://flash.patnakajima.net).

## Usage

Here's how to use it.

### Vanilla Rack apps

You can access flash entries via `env['rack-flash']`. You can treat it either like a regular
flash hash (via the `env['rack-flash'][:notice]` style), or you can pass the `:accessorize`
option when you call `use Rack::Flash`, and you'll be able to use the accessor style, which
generates accessors on the fly (`env['rack-flash'].notice` and the like).

Sample rack app:

    get = proc { |env|
      [200, {},
        env['rack-flash'].notice || 'No flash set. Try going to /set'
      ]
    }

    set = proc { |env|
      env['rack-flash'].notice = 'Hey, the flash was set! Now refresh and watch it go away.'
      [302, {'Location' => '/'},
        'You are being redirected.'
      ]
    }

    builder = Rack::Builder.new do
      use Rack::Session::Cookie
      use Rack::Flash, :accessorize => true

      map('/set') { run set }
      map('/')    { run get }
    end

    Rack::Handler::Mongrel.run builder, :Port => 9292

### Sinatra

If you're using Sinatra, you can use the flash hash just like in Rails:

    require 'sinatra/base'
    require 'rack-flash'

    class MyApp < Sinatra::Base
      use Rack::Flash

      get '/' do
        flash[:greeting] || "No greeting..."
      end

      get '/greeting' do
        flash[:greeting] = params[:q]
        redirect '/'
      end

      run!
    end

If you've got any ideas on how to simplify access to the flash hash for non-Sinatra
apps, let me know. It still feels a bit off to me.