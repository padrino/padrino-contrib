module Padrino
  module Contrib
    module Orm
      module ActiveRecord
        ##
        # This module extend ActiveRecord.
        #
        # You need to to your model a column called +:permalink+
        #
        # then use +has_permalink :title like:
        #
        #   class Page < ActiveRecord::Base
        #     has_permalink :page
        #   end
        #
        module Permalink
          module ClassMethods
            def has_permalink(field)
              include InstanceMethods
              @_permalink_field = field
              before_save :generate_permalink
            end

            def permalink_field
              @_permalink_field
            end
          end # ClassMethods

          module InstanceMethods
            def to_param
              permalink
            end

            protected
              def generate_permalink
                self.permalink = read_attribute(self.class.permalink_field).downcase.
                  gsub(/\W/, '-').gsub(/-+/, '-').gsub(/-$/, '').gsub(/^-/, '')
              end
          end # InstanceMethods
        end # Permalink
      end # ActiveRecord
    end # Orm
  end # Contrib
end # Padrino
::ActiveRecord::Base.extend(Padrino::Contrib::Orm::ActiveRecord::Permalink::ClassMethods)
