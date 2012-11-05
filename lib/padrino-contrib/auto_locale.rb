module Padrino
  module Contrib
    ##
    # This extension give to padrino the ability to change
    # their locale inspecting.
    #
    # ==== Usage
    #
    #   class MyApp < Padrino::Application
    #     register Padrino::Contrib::AutoLocale
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
          return unless settings.locales.include?(lang)
          if request.path_info[/\/#{I18n.locale}\//]
            request.path_info.sub(/\/#{I18n.locale}\//, "/#{lang}/") 
          else
            request.path_info.sub(/\/$/, "/#{lang}")
          end
        end
      end # Helpers

      def self.registered(app)
        app.helpers Padrino::Contrib::AutoLocale::Helpers
        app.extend ClassMethods
        app.set :locales, [:en]
        app.before do
          if request.path_info =~ /^\/(#{settings.locales.join('|')})\b/
            I18n.locale = $1.to_sym
          else
            I18n.locale = settings.locales[0]
            not_found if request.path_info !~ /^\/?$/
          end
        end

        def self.padrino_route_added(route, verb, path, args, options, block)
          route.instance_variable_set(:@original_path, "/(:lang)#{route.original_path}") unless route.original_path =~/:lang/
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
