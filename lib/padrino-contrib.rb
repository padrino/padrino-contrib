module Padrino
  module Contrib
    autoload :VERSION, 'padrino-contrib/version.rb'
    autoload :AutoLocale, 'padrino-contrib/auto_locale.rb'
    autoload :ExceptionNotifier, 'padrino-contrib/exception_notifier.rb'

    module Helpers
      autoload :Breadcrumbs, 'padrino-contrib/helpers/breadcrumbs.rb'
    end # Helpers
  end # Contrib
end # Padrino

if defined?(ActiveRecord)
  Dir[File.join(File.expand_path('../', __FILE__), '/padrino-contrib/orm/active_record/**/*.rb')].sort.each { |d| require d }
end
