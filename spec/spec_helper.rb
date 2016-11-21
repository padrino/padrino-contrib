RACK_ENV = 'test'
PADRINO_ROOT = File.dirname(__FILE__) unless defined?(PADRINO_ROOT)
require 'rubygems' unless defined?(Gem)
require 'bundler'
Bundler.require(:default, RACK_ENV)

require_relative 'support/matchers/have_selector'
require 'padrino-contrib'

RSpec.configure do |config|
  config.include Rack::Test::Methods

  # Sets up a Sinatra::Base subclass defined with the block
  # given. Used in setup or individual spec methods to establish
  # the application.
  def mock_app(base=Padrino::Application, &block)
    @app = Sinatra.new(base, &block)
  end

  def app
    @app
  end
end
