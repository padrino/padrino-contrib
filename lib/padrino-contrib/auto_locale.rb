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
    #     set :locale_exclusive_paths, ['/js', '/css', '/img'] # asset uri paths which shouldn't be localized
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
        app.set :locale_exclusive_paths, []
        @@exclusive_paths = false
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
            # Urls which are not "/" or "/:lang/..." style are invalid. But first we should check if it's an asset path.
            unless @@exclusive_paths.is_a?(Array)
              if settings.respond_to?(:assets) and
                settings.assets.respond_to?(:served) and
                settings.assets.served.is_a?(Hash)
                # auto include sinatra-assetpack configuration
                @@exclusive_paths = settings.locale_exclusive_paths + settings.assets.served.keys
              else
                @@exclusive_paths = settings.locale_exclusive_paths
              end
            end

            # Return 404 Not Found for invalid urls, unless it's an asset path.
            not_found unless @@exclusive_paths.detect do |path|
              if path.is_a?(Regexp)
                !!path.match(request.path_info)
              elsif path.is_a?(String)
                request.path_info.start_with?(path.end_with?("/") ? path : "#{path}/")
              end
            end
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
          params[:lang] ||= I18n.locale
          args << params
          super(*args)
        end
      end
    end # AutoLocale
  end # Contrib
end # Padrino
