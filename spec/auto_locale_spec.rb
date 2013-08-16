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

    it "doesn't choke when the HTTP_ACCEPT_LANGUAGE header is not present" do
      expect do
        get '/', { }, 'HTTP_ACCEPT_LANGUAGE' => nil
      end.not_to raise_exception NoMethodError
    end
  end

  it 'returns 404 when requesting an unlocalized path' do
    get '/bar'
    expect(last_response).to be_not_found
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
end
