module Padrino
  module Contrib
    autoload :VERSION, 'padrino-contrib/version.rb'
    autoload :AutoLocale, 'padrino-contrib/auto_locale.rb'
    autoload :ExceptionNotifier, 'padrino-contrib/exception_notifier.rb'
    autoload :FlashSession, 'padrino-contrib/flash_session'

    module Helpers
      autoload :AssetsCompressor, 'padrino-contrib/helpers/assets_compressor.rb'
    end # Helpers
  end # Contrib
end # Padrino