module Padrino
  module Contrib
    module Orm
      module Mm
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
              validates_uniqueness_of field
              key :permalink, String
            end

            def permalink_for(name)
              name.downcase.gsub(/\W/, '-').
                            gsub(/-+/, '-').
                            gsub(/-$/, '').
                            gsub(/^-/, '')
            end
          end

          module InstanceMethods
            def to_param
              permalink
            end

            protected
              def generate_permalink
                self.permalink = self.class.permalink_for(self[permalink_field])
              end
          end # InstanceMethods
        end # Permalink
      end # Mm
    end # Orm
  end # Contrib
end # Padrino
MongoMapper::Document.append_extensions(Padrino::Contrib::Orm::Mm::Permalink::ClassMethods)