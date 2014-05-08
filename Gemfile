source "https://rubygems.org"

# Specify your gem's dependencies in padrino-contrib.gemspec
gemspec

gem 'i18n'

group :development do
  gem 'rake'
end

group :test, :development do
  gem 'pry-debugger' unless ENV['TRAVIS']
end

group :test do
  gem 'padrino-core'
  gem 'padrino-helpers'
  gem 'padrino-mailer'
  gem 'rspec'
  gem 'rack-test'
end
