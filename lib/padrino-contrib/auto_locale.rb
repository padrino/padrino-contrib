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
          request.path_info.sub(/\/#{I18n.locale}/, "/#{lang}") if settings.locales.include?(lang)
        end
      end # Helpers

      def self.registered(app)
        app.helpers Padrino::Contrib::AutoLocale::Helpers
        app.extend ClassMethods
        app.set :locales, [:en]
        app.before do
          if request.path_info =~ /^\/(#{settings.locales.join('|')})\b/
            I18n.locale = $1.to_sym

          elsif request.path_info =~ /^\/?$/
            # Root path "/" needs special treatment, as it doesn't contain any language parameter.

            # First guess the preferred language from the http header
            for browser_locale in request.env['HTTP_ACCEPT_LANGUAGE'].split(",")
              locale = browser_locale.split(";").first.downcase.sub('-', '_')
              if settings.locales.include?(locale.to_sym)
                I18n.locale = locale.to_sym
                break
              end
            end
            # If none found use the default locale
            I18n.locale ||= settings.locales[0]

            # Then redirect from "/" to "/:lang" to match the new routing urls
            redirect "/#{I18n.locale.to_s}/"

          else
            # Urls should be either "/" or "/:lang/..." style, otherwise return 404 error
            not_found
          end
        end

        def self.padrino_route_added(route, verb, path, args, options, block)
          ##
          # TODO: Regex original_path needs to be served as well.
          #
          return unless route.original_path.is_a?(String)
          route.path = "/:lang#{route.original_path}" unless route.original_path =~/:lang/
        end
      end

      module ClassMethods
        ##
        # We need to add always a lang to all our routes
        #
        def url(*args)
          params = args.extract_options!
          params[:lang] = I18n.locale
          args << params
          super(*args)
        end
      end
    end # AutoLocale
  end # Contrib
end # Padrino
