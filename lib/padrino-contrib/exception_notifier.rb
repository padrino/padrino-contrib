##
# This is an exception notifier for Padrino::Application with
# redmine bonus feature.
#
# ==== Usage
#
#   class MyApp < Padrino::Application
#     register Padrino::Contrib::ExceptionNotifier
#     set :exceptions_from,    "errors@localhost.local"
#     set :exceptions_to,      "foo@bar.local"
#     set :exceptions_page,    :errors # => views/errors.haml/erb
#     set :redmine, :project => "My Bugs", :tracker => "Bugs", :priority => "High"
#     # Params and env keys containing any of these words (or matching a Regexp) are filtered
#     set :exceptions_params_filter, ['password', 'secret', 'token', /\Apin\z/i]
#     # Uncomment this for test in development
#     # disable :raise_errors
#     # disable :show_exceptions
#   end
#
module Padrino
  module Contrib
    module ExceptionNotifier
      FILTERED = Object.new
      def FILTERED.inspect; '[FILTERED]'; end
      def FILTERED.to_s; '[FILTERED]'; end
      FILTERED.freeze

      # Env entries that are never reported: cookies, credentials, session data and raw form bodies.
      MASKED_ENV = /\A(?:HTTP_COOKIE|HTTP_AUTHORIZATION|HTTP_PROXY_AUTHORIZATION|rack\.session|rack\.request\.(?:cookie|form))/
      # Env entries holding a URL or a query string, reported with filtered query values.
      URL_ENV   = %w(REQUEST_URI ORIGINAL_FULLPATH HTTP_REFERER)
      QUERY_ENV = %w(QUERY_STRING rack.request.query_string)
      REPORTED_ENV_TYPES = [String, Symbol, Numeric, TrueClass, FalseClass]

      def self.registered(app)
        app.set :exceptions_subject, "Exception" unless app.respond_to?(:exceptions_subject)
        app.set :exceptions_to,      "errors@localhost.local" unless app.respond_to?(:exceptions_to)
        app.set :exceptions_from,    "foo@bar.local" unless app.respond_to?(:exceptions_from)
        app.set :exceptions_layout,  :application unless app.respond_to?(:exceptions_layout)
        app.set :exceptions_views,   app.views unless app.respond_to?(:exceptions_views)
        app.set :redmine, {} unless app.respond_to?(:redmine)
        app.set :exceptions_params_filter, ['password', 'password_confirmation', 'secret', 'token', 'api_key'] unless app.respond_to?(:exceptions_params_filter)
        app.error 500 do
          boom = env['sinatra.error']
          body = ExceptionNotifier.report(boom, env, params, settings.exceptions_params_filter)
          logger.error body
          settings.redmine.each { |k,v| body += "\n#{k.to_s.capitalize}: #{v}" }
          app.email do
            subject "[#{app.exceptions_subject}] #{boom.class} - #{boom.message}"
            to app.exceptions_to
            from app.exceptions_from
            body body
          end
          response.status = 500
          content_type 'text/html', :charset => "utf-8"
          render settings.exceptions_page, :layout => settings.exceptions_layout, :views => settings.exceptions_views
        end
        app.not_found do
          response.status = 404
          content_type 'text/html', :charset => "utf-8"
          render settings.exceptions_page, :layout => settings.exceptions_layout, :views => settings.exceptions_views
        end
      end # self.registered

      ##
      # Builds the plain text report for an exception, with params and env filtered.
      #
      def self.report(boom, env, params, filters)
        body  = ["#{boom.class} - #{utf8(boom.message.to_s)}:", *boom.backtrace].join("\n  ")
        body += "\n\n---Env:\n"
        env.each do |key, value|
          next unless REPORTED_ENV_TYPES.any? { |type| value.is_a?(type) }
          body += "\n#{key}: #{filter_env(key.to_s, value.is_a?(String) ? utf8(value) : value, filters)}"
        end
        body += "\n\n---Params:\n"
        filter_params(params, filters).each { |key, value| body += "\n#{key.inspect} => #{value.inspect}" }
        body
      end

      ##
      # Returns a filtered copy of params, following nested hashes and arrays.
      #
      def self.filter_params(value, filters)
        case value
        when Hash
          value.each_with_object({}) do |(key, nested), copy|
            copy[key] = filtered_key?(key, filters) ? FILTERED : filter_params(nested, filters)
          end
        when Array
          value.map { |nested| filter_params(nested, filters) }
        else
          value
        end
      end

      def self.filtered_key?(key, filters)
        key = utf8(key.to_s)
        filters.any? do |filter|
          filter.is_a?(Regexp) ? filter.match?(key) : key.downcase.include?(filter.to_s.downcase)
        end
      end

      def self.filter_env(key, value, filters)
        return FILTERED if key =~ MASKED_ENV || filtered_key?(key, filters)
        return filter_query(value.to_s, filters) if QUERY_ENV.include?(key)
        if URL_ENV.include?(key)
          path, query = value.to_s.split('?', 2)
          return query ? "#{path}?#{filter_query(query, filters)}" : value
        end
        value
      end

      def self.filter_query(query, filters)
        query.split(/([&;])/).map do |pair|
          raw_name, separator, _value = pair.partition('=')
          next pair if separator.empty?
          name = begin
            utf8(::Rack::Utils.unescape(raw_name))
          rescue ArgumentError
            raw_name
          end
          filtered = name.scan(/[^\[\]]+/).any? { |part| filtered_key?(part, filters) }
          filtered ? "#{raw_name}=#{FILTERED}" : pair
        end.join
      end

      # A UTF-8 copy with invalid bytes replaced, so reports never fail on request data.
      def self.utf8(string)
        String.new(string, :encoding => Encoding::UTF_8).scrub
      end
    end # ExceptionNotifier
  end # Contrib
end # Padrino
