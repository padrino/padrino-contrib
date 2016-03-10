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
      end.not_to raise_exception NoMethodError
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
  end
end
