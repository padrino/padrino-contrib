source "https://rubygems.org"

# Specify your gem's dependencies in padrino-contrib.gemspec
gemspec

gem 'i18n'

group :development do
  gem 'rake'
end

group :test do
  # Set ACTIVESUPPORT=1 to run the specs with ActiveSupport loaded first.
  gem 'activesupport', :require => 'active_support/all' if ENV['ACTIVESUPPORT']

  # Set ACTIVERECORD=1 to also run the ActiveRecord extension specs, on SQLite.
  if ENV['ACTIVERECORD']
    gem 'activerecord', '>= 6.1', :require => false
    gem 'sqlite3', '>= 1.4', :require => false
  end

  # Set PADRINO_PATH to a padrino-framework checkout to test against it.
  padrino_gems = %w(padrino-support padrino-core padrino-helpers padrino-mailer)
  if ENV['PADRINO_PATH']
    padrino_gems.each { |name| gem name, :path => File.join(ENV['PADRINO_PATH'], name) }
  else
    padrino_gems.each { |name| gem name }
  end
  gem 'rspec'
  gem 'rack-test'
  gem 'oga'
end
