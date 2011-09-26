require 'rack/utils'

module Padrino
  module Contrib
    ##
    # This Middleware help you passing your session in the URI, when it should be in the cookie.
    #
    # This code it's only performed when:
    #
    #   env['HTTP_USER_AGENT'] =~ /^(Adobe|Shockwave) Flash/
    #
    # ==== Usage
    #
    #  use Padrino::Contrib::FlashSession, settings.session_id
    #
    class FlashSession

      def self.registered(app)
        app.use Padrino::Contrib::FlashSession, app.session_id
      end

      def initialize(app, session_key = 'session_id')
        @app = app
        @session_key = session_key.to_s
      end

      def call(env)
        if env['HTTP_USER_AGENT'] =~ /^(Adobe|Shockwave) Flash/
          params = ::Rack::Request.new(env).params
          env['rack.session'] ||= {}
          env['rack.session'][@session_key.to_sym] = params[@session_key] if params[@session_key].present?
        end
        @app.call(env)
      end
    end # FlashSession
  end # Contrib
end # Padrino
