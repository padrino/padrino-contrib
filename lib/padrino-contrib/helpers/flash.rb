module Padrino
  module Contrib
    module Helpers
      ##
      # Dead simple version of rack-flash.
      # You still use flash without session, but remember that
      # they can't work after a redirect.
      #
      # ==== Usage:
      #
      #   register Padrino::Contrib::Helpers::Flash
      #
      module Flash
        def self.registered(app)
          app.before { @_flash, session[:_flash] = session[:_flash], nil if settings.sessions? && session[:_flash] }
          app.helpers InstanceMethods
        end

        module InstanceMethods
          def flash
            @_flash ||= {}
          end

          def redirect(uri, *args)
            session[:_flash] = @_flash if settings.sessions? && flash.present?
            super(uri, *args)
          end
        end
      end # Flash
    end # Helpers
  end # Contrib
end # Padrino
