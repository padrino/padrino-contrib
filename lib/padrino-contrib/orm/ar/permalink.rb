module Padrino
  module Contrib
    module Orm
      module Ar
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
              class_inheritable_accessor  :permalink_field
              write_inheritable_attribute :permalink_field, field
              before_save :generate_permalink
            end
          end # ClassMethods

          module InstanceMethods
            def to_param
              permalink
            end

            protected
              def generate_permalink
                self.permalink = read_attribute(permalink_field).downcase.
                                                                 gsub(/\W/, '-').
                                                                 gsub(/-+/, '-').
                                                                 gsub(/-$/, '').
                                                                 gsub(/^-/, '')
              end
          end # InstanceMethods
        end # Permalink
      end # Ar
    end # Orm
  end # Contrib
end # Padrino
ActiveRecord::Base.extend(Padrino::Contrib::Orm::Ar::Permalink::ClassMethods)