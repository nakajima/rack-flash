require File.dirname(__FILE__) + '/helper'

describe 'Rack::Flash' do
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
  
  describe 'session integration' do
    before do
      mock_app {
        use Rack::Flash

        set :sessions, true

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
  end
  
  # Testing sessions is a royal pain in the ass.
end