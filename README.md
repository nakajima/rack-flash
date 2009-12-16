# Rack Flash

    flash[:notice] = "You can stop rolling your own now."

Simple flash hash implementation for Rack apps.

[View the RDoc](http://gitrdoc.com/nakajima/rack-flash/tree/master).

## Usage

Here's how to use it.

### Vanilla Rack apps

You can access flash entries via `env['x-rack.flash']`. You can treat it either
like a regular flash hash:

    env['x-rack.flash'][:notice] = 'You have logged out.'

Or you can pass the `:accessorize` option to declare your flash types. Each of
these will have accessors defined on the flash object:

    use Rack::Flash, :accessorize => [:notice, :error]
    
    # Set a flash entry
    env['x-rack.flash'].notice = 'You have logged out.'
    
    # Get a flash entry
    env['x-rack.flash'].notice # => 'You have logged out.'
    
    # Set a a flash entry for only the current request
    env['x-rack.flash'].notice! 'You have logged out.'

Sample rack app:

    get = proc { |env|
      [200, {},
        env['x-rack.flash'].notice || 'No flash set. Try going to /set'
      ]
    }

    set = proc { |env|
      env['x-rack.flash'].notice = 'Hey, the flash was set!'
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

      post '/set-flash' do
        # Set a flash entry
        flash[:notice] = "Thanks for signing up!"
        
        # Get a flash entry
        flash[:notice] # => "Thanks for signing up!"
        
        # Set a flash entry for only the current request
        flash.now[:notice] = "Thanks for signing up!"
      end
    end

If you've got any ideas on how to simplify access to the flash hash for vanilla
Rack apps, let me know. It still feels a bit off to me.

## Sweeping stale entries

By default Rack::Flash has slightly different behavior than Rails in that it
doesn't delete entries until they are used. If you want entries to be cleared
even if they are not ever accessed, you can use the `:sweep` option:

    use Rack::Flash, :sweep => true

This will sweep stale flash entries, whether or not you actually use them.