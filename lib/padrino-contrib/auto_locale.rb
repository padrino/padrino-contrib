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
    # A String in locale_exclusive_paths excludes that path and everything below it
    # ('/js' excludes /js and /js/app.js, not /jsfoo). With Warden, exclude its
    # failure path ('/unauthenticated') so failed logins reach the login page.
    #
    module AutoLocale
      module Helpers
        ##
        # This reload the page changing the I18n.locale
        #
        def switch_to_lang(lang)
          return unless settings.locales.include?(lang)
          return url("/#{lang}") if request.path_info == '/'
          url(request.path_info.sub(/\A\/#{I18n.locale}\b/, "/#{lang}"))
        end
      end # Helpers

      def self.registered(app)
        app.helpers Padrino::Contrib::AutoLocale::Helpers
        app.extend ClassMethods
        app.set :locales, [:en]
        app.set :locale_exclusive_paths, []
        app.before do
          # Gather excluded paths of this app, auto including sinatra-assetpack configuration
          exclusive_paths = settings.locale_exclusive_paths
          if settings.respond_to?(:assets) and
            settings.assets.respond_to?(:served) and
            settings.assets.served.is_a?(Hash)
            exclusive_paths += settings.assets.served.keys
          end

          # Default to the first locale
          I18n.locale = settings.locales.first

          # First check if the path starts with a known locale
          if request.path_info =~ /^\/(#{settings.locales.join('|')})\b/
            I18n.locale = $1.to_sym

          # Then check if the path is excluded
          elsif AutoLocale.excluded_path?(request.path_info, exclusive_paths)
            next

          # Root path "/" needs special treatment, as it doesn't contain any language parameter.
          elsif request.path_info =~ /^\/?$/
            # Try to guess the preferred language from the http header
            for browser_locale in (request.env['HTTP_ACCEPT_LANGUAGE'] || '').split(",")
              locale = browser_locale.split(";").first.downcase.split("-").first
              if settings.locales.include?(locale.to_sym)
                I18n.locale = locale.to_sym
                break
              end
            end
            # Then redirect from "/" to "/:lang" to match the new routing urls
            redirect url("/#{I18n.locale.to_s}/")

          # Return 404 not found for everything else
          else
            not_found
          end
        end

        def self.padrino_route_added(route, verb, path, args, options, block)
          ##
          # TODO: Regex original_path needs to be served as well.
          #
          return unless route.original_path.is_a?(String)
          excluded_paths = block.binding.eval('settings').locale_exclusive_paths
          return if AutoLocale.excluded_path?(route.original_path, excluded_paths)
          route.path = "/:lang#{route.original_path}" unless route.original_path =~ /:lang/
        end

        def self.excluded_path?(path, excluded_paths)
          excluded_paths.detect do |excluded_path|
            if excluded_path.is_a?(Regexp)
              !!excluded_path.match(path)
            elsif excluded_path.is_a?(String)
              path == excluded_path ||
                path.start_with?(excluded_path.end_with?("/") ? excluded_path : "#{excluded_path}/")
            end
          end
        end
      end

      module ClassMethods
        ##
        # We need to add always a lang to all our routes
        #
        def url(*args)
          params = args.last.is_a?(Hash) ? args.pop : {}
          params[:lang] ||= I18n.locale
          args << params
          super(*args)
        end
      end
    end # AutoLocale
  end # Contrib
end # Padrino
