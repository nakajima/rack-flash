require File.dirname(__FILE__) + '/helper'

describe 'Rack::Flash' do
  include Rack::Test::Methods

  def app(&block)
    return Sinatra.new &block
  end

  before do
    @fake_session = {}
  end

  def new_flash(entries={})
    flash = Rack::Flash::FlashHash.new(@fake_session)
    entries.each { |key,val| flash[key] = val }
    flash
  end

  it 'stores entries' do
    new_flash[:foo] = 'bar'
    new_flash[:foo].should.equal('bar')
  end

  it 'accepts strings or hashes' do
    new_flash[:foo] = 'bar'
    new_flash['foo'].should.equal('bar')
  end

  it 'deletes entries from session after retrieval' do
    new_flash[:foo] = 'bar'
    new_flash[:foo]
    new_flash[:foo].should.be.nil
  end

  it 'caches retrieved entries in instance' do
    flash = new_flash(:foo => 'bar')
    flash[:foo].should.equal('bar')
    flash[:foo].should.equal('bar')
  end

  it 'does not step on session keys' do
    @fake_session[:foo] = true
    new_flash[:foo] = false
    @fake_session[:foo].should.be.true
  end

  it 'can flag existing entries' do
    flash = new_flash(:foo => 'bar', :fizz => 'buzz')
    flash.flag!
    flash.flagged.should.include(:foo)
    flash.flagged.should.include(:fizz)
  end

  it 'can sweep flagged entries' do
    err_explain do
      flash = new_flash(:foo => 'bar', :fizz => 'buzz')
      flash.flag!
      flash.sweep!
      flash.flagged.should.be.empty
      new_flash[:foo].should.be.nil
      new_flash[:fizz].should.be.nil
    end
  end

  it 'allows setters with Flash.now semantics' do
    flash = new_flash
    flash.now[:foo] = 'bar'
    flash[:foo].should.equal('bar')
    new_flash[:foo].should.be.nil
  end

  it 'does not raise an error when session is cleared' do
    flash = new_flash
    flash[:foo] = 'bar'
    @fake_session.clear
    flash['foo'].should.equal(nil)
  end

  describe 'accessorize option' do
    def new_flash(entries={})
      flash = Rack::Flash::FlashHash.new(@fake_session, :accessorize => [:foo, :fizz])
      entries.each { |key,val| flash[key] = val }
      flash
    end

    it 'allows getters' do
      flash = new_flash(:foo => 'bar')
      flash.foo.should.equal('bar')
    end

    it 'allows setters' do
      flash = new_flash
      flash.fizz = 'buzz'
      flash.fizz.should.equal('buzz')
    end

    it 'allows declarative setters' do
      flash = new_flash
      flash.fizz 'buzz'
      flash.fizz.should.equal('buzz')
    end

    it 'allows setters with Flash.now semantics' do
      flash = new_flash
      flash.foo! 'bar'
      flash.foo.should.equal('bar')
      new_flash[:foo].should.be.nil
    end

    it 'only defines accessors for passed entry types' do
      err_explain do
        flash = new_flash
        proc {
          flash.bliggety = 'blam'
        }.should.raise(NoMethodError)
      end
    end
  end

  it 'does not provide getters by default' do
    proc {
      new_flash(:foo => 'bar').foo
    }.should.raise(NoMethodError)
  end

  it 'does not provide setters by default' do
    proc {
      flash = new_flash
      flash.fizz = 'buzz'
    }.should.raise(NoMethodError)
  end

  describe 'integration' do
    it 'provides :sweep option to clear unused entries' do
      app {
        use Rack::Flash, :sweep => true

        set :sessions, true

        get '/' do
          'ok'
        end
      }

      fake_flash = Rack::FakeFlash.new(:foo => 'bar')

      get '/', :env=>{ 'x-rack.flash' => fake_flash }

      fake_flash.should.be.flagged
      fake_flash.should.be.swept
      fake_flash.store[:foo].should.be.nil
    end
  end

  # Testing sessions is a royal pain in the ass.
end