require 'spec_helper'

describe Padrino::Contrib::AutoLocale do
  before :all do
    mock_app {
      register Padrino::Contrib::AutoLocale

      get(:foo) { 'foo' }
    }
  end

  describe 'overloaded #url' do
    it 'prepends the default lang' do
      expect(@app.url(:foo)).to eq '/en/foo'
    end

    it 'allows overriding lang' do
      expect(@app.url(:foo, lang: 'ru')).to eq '/ru/foo'
    end
  end
end
