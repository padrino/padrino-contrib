require 'spec_helper'

describe Padrino::Contrib::AutoLocale do
  before :all do
    mock_app {
      register Padrino::Contrib::AutoLocale
      set :locales, [ :es, :en, :ru ]

      get('/') { 'root' }
      get('/bar') { 'bar' }
      get(:foo) { 'foo' }
    }
  end
  after(:each) { I18n.locale = I18n.default_locale }

  describe 'when requesting a localized path' do
    it 'sets I18n.locale to the requested locale' do
      expect { get '/ru' }.to change { I18n.locale }.to :ru
    end

    it 'returns 404 if requesting an unsupported locale' do
      get '/ja'
      expect(last_response).to be_not_found
    end
  end

  describe "when requesting the root path '/'" do
    it 'redirects to the default locale' do
      get '/'
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.path_info).to eq "/#{@app.locales.first}/"
    end

    it 'sets I18n.locale to the first locale' do
      expect { get '/' }.to change { I18n.locale }.to @app.locales.first
    end

    it "doesn't choke when the HTTP_ACCEPT_LANGUAGE header is not present" do
      expect do
        get '/', { }, 'HTTP_ACCEPT_LANGUAGE' => nil
      end.not_to raise_error
    end
  end

  describe 'when setting locale_exclusive_paths' do
    before :each do
      mock_app {
        register Padrino::Contrib::AutoLocale
        set :locales, [ :es, :en ]
        set :locale_exclusive_paths, [ '/unlocalized' ]
        get('/bar') { 'bar' }
        get('/unlocalized/path') { 'unlocalized path' }
      }
    end

    it 'returns 404 if the path is not excluded' do
      get '/bar'
      expect(last_response).to be_not_found
    end

    context 'when the path is excluded' do
      it 'does not prepend :lang to the route' do
        expect(@app.routes.last.original_path).not_to match /:lang/
      end

      it 'lets the request through' do
        get '/unlocalized/path'
        expect(last_response).to be_ok
        expect(last_response.body).to eq 'unlocalized path'
      end

      it 'sets I18n.locale to the first locale' do
        expect { get '/unlocalized/path' }.to change { I18n.locale }.to @app.locales.first
      end
    end

    context 'when the path is the excluded path itself' do
      before :each do
        @app.post('/unlocalized') { 'unlocalized exact' }
        @app.get('/unlocalizedfoo') { 'not excluded' }
      end

      it 'does not prepend :lang to the route' do
        expect(@app.routes.map(&:path)).to include '/unlocalized'
        expect(@app.routes.map(&:path)).not_to include '/:lang/unlocalized'
      end

      it 'lets the request through' do
        post '/unlocalized'
        expect(last_response).to be_ok
        expect(last_response.body).to eq 'unlocalized exact'
      end

      it 'still localizes paths that only share the prefix' do
        get '/unlocalizedfoo'
        expect(last_response).to be_not_found
        get '/en/unlocalizedfoo'
        expect(last_response.body).to eq 'not excluded'
      end
    end

    it 'allows excluding the root path "/"' do
      @app.locale_exclusive_paths << /^\/?$/
      @app.get('/') { 'root path' }
      get '/'
      expect(last_response).not_to be_redirect
      expect(last_response.body).to eq 'root path'
    end
  end

  describe 'overloaded #url' do
    before(:each) { get '/en' }

    it 'prepends the current lang' do
      expect(@app.url(:foo)).to eq '/en/foo'
    end

    it 'allows overriding lang' do
      expect(@app.url(:foo, :lang => 'ru')).to eq '/ru/foo'
    end
  end

  describe '#switch_to_lang' do
    before :all do
      mock_app {
        register Padrino::Contrib::AutoLocale
        set :locales, [ :es, :en ]
        set :locale_exclusive_paths, [ /^\/?$/, '/unlocalized' ]

        get('/(:lang)?') { switch_to_lang(:en) }
        get('/unlocalized/path') { switch_to_lang(:en) }
        get('/unlocalized/estate') { switch_to_lang(:en) }
      }
    end

    it 'returns the current localized path switched to the requested lang' do
      get '/es'
      expect(last_response.body).to eq '/en'
    end

    it 'switches the unlocalized root path to the requested lang' do
      get '/'
      expect(last_response.body).to eq '/en'
    end

    it 'returns the same path if the path is not localized' do
      get '/unlocalized/path'
      expect(last_response.body).to eq '/unlocalized/path'
    end

    it 'only replaces a leading locale segment' do
      get '/unlocalized/estate'
      expect(last_response.body).to eq '/unlocalized/estate'
    end
  end

  describe 'with several applications' do
    it 'uses the excluded paths of the application serving the request' do
      excluding_root = mock_app {
        register Padrino::Contrib::AutoLocale
        set :locales, [ :en ]
        set :locale_exclusive_paths, [ /^\/?$/ ]
        get('/') { 'root path' }
      }
      localized = mock_app {
        register Padrino::Contrib::AutoLocale
        set :locales, [ :en ]
      }

      expect(Rack::MockRequest.new(localized).get('/')).to be_redirect
      response = Rack::MockRequest.new(excluding_root).get('/')
      expect(response).not_to be_redirect
      expect(response.body).to eq 'root path'
    end
  end

  describe 'when mounted at a sub-path' do
    before :each do
      blog = mock_app {
        register Padrino::Contrib::AutoLocale
        set :locales, [ :en, :de ]
        set :uri_root, '/blog'

        get(:posts) { switch_to_lang(:de) }
      }
      @app = Padrino::Router.new(:path => '/blog', :to => blog)
    end

    around :each do |example|
      base_uri = ENV.delete('RACK_BASE_URI')
      begin
        example.run
      ensure
        base_uri ? ENV['RACK_BASE_URI'] = base_uri : ENV.delete('RACK_BASE_URI')
      end
    end

    it 'redirects the root path to the localized root under the mount point' do
      get '/blog/'
      expect(last_response).to be_redirect
      expect(URI(last_response.location).path).to eq '/blog/en/'
    end

    it 'redirects the root path under RACK_BASE_URI' do
      ENV['RACK_BASE_URI'] = '/sub'
      get '/blog/'
      expect(last_response).to be_redirect
      expect(URI(last_response.location).path).to eq '/sub/blog/en/'
    end

    it 'switches the lang of a localized path under the mount point' do
      get '/blog/en/posts'
      expect(last_response.body).to eq '/blog/de/posts'
    end

    it 'switches the lang of a localized path under RACK_BASE_URI' do
      ENV['RACK_BASE_URI'] = '/sub'
      get '/blog/en/posts'
      expect(last_response.body).to eq '/sub/blog/de/posts'
    end
  end
end
