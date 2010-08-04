##
# Manages current Padrino Contrib version for use in gem generation.
#
# We put this in a separate file so you can get padrino version
# without include full padrino contrib.
#
module Padrino
  module Contrib
    VERSION = '0.0.1' unless defined?(Padrino::Contrib::VERSION)
    ##
    # Return the current Padrino version
    #
    def self.version
      VERSION
    end
  end # Contrib
end # Padrino