module Padrino
  module Contrib
    autoload :VERSION, 'padrino-contrib/version.rb'
    autoload :AutoLocale, 'padrino-contrib/auto_locale.rb'
    autoload :ExceptionNotifier, 'padrino-contrib/exception_notifier.rb'
    autoload :FlashSession, 'padrino-contrib/flash_session'

    module Helpers
      autoload :AssetsCompressor, 'padrino-contrib/helpers/assets_compressor.rb'
      autoload :JQuery, 'padrino-contrib/helpers/jquery.rb'
      autoload :Flash, 'padrino-contrib/helpers/flash.rb'
    end # Helpers
  end # Contrib
end # Padrino

if defined?(ActiveRecord)
  Dir[File.join(File.expand_path('../', __FILE__), '/padrino-contrib/orm/active_record/**/*.rb')].sort.each { |d| require d }
end

if defined?(MongoMapper)
  Dir[File.join(File.expand_path('../', __FILE__), '/padrino-contrib/orm/mongo_mapper/**/*.rb')].sort.each { |d| require d }
end
