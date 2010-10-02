module Padrino
  module Contrib
    ##
    # This extension give to padrino the ability to change
    # their locale inspecting.
    #
    # ==== Usage
    #
    #   class MyApp < Padrino::Application
    #     register AutoLocale
    #     set :locales, [:en, :ru, :de] # First locale is the default locale
    #   end
    #
    #   # view.haml
    #   =link_to "View this page in RU Version", switch_to_lang(:ru)
    #
    # So when we call an url like: /ru/blog/posts this extension set for you :ru as I18n.locale
    #
    module AutoLocale
      module Helpers
        ##
        # This reload the page changing the I18n.locale
        #
        def switch_to_lang(lang)
          request.path_info.sub(/\/#{I18n.locale}/, "/#{lang}") if options.locales.include?(lang)
        end

        def url(*args)
          "/#{I18n.locale}#{super}"
        end
      end # Helpers

      def self.registered(app)
        app.helpers Padrino::Contrib::AutoLocale::Helpers
        app.set :locales, [:en]
        app.before do
          if request.path_info =~ /^\/(#{options.locales.join('|')})(?=\/|$)/
            I18n.locale = $1.to_sym
            request.path_info.sub!(/^\/(#{$1})\/?/) { $2 || '' }
            request.path_info.replace('/') if request.path_info.empty?
          else
            I18n.locale = options.locales.first
          end
        end
      end # self.registered
    end # AutoLocale
  end # Contrib
end # Padrino