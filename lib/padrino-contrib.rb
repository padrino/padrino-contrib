module Padrino
  module Contrib
    autoload :AutoLocale, 'padrino-contrib/auto_locale.rb'
    autoload :ExceptionNotifier, 'padrino-contrib/exception_notifier.rb'
    autoload :FlashSession, 'padrino-contrib/flash_session'

    module Helpers
      autoload :AssetsCompressor, 'padrino-contrib/assets_compressor.rb'
    end # Helpers
  end # Contrib
end # Padrino