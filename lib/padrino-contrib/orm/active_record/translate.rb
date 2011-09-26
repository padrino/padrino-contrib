module Padrino
  module Contrib
    module Orm
      module ActiveRecord
        ##
        # This is an extension for ActiveRecord where if I had:
        #
        #   post.description_ru = "I'm Russian"
        #   post.description_en = "I'm English"
        #   post.description_it = "I'm Italian"
        #
        # with this extension if I had set:
        #
        #   I18n.locale = :it
        #
        # calling directly:
        #
        #   post.description
        #
        # will be a shortcut for:
        #
        #  post.description_it => "I'm Italian"
        #
        module Translate
          module ClassMethods
            def has_locale
              include InstanceMethods
            end
          end # ClassMethods

          module InstanceMethods
            def method_missing(method_name, *arguments)
              attribute = "#{method_name}_#{I18n.locale}".to_sym
              return self.send(attribute) if I18n.locale.present? && self.respond_to?(attribute)
              super
            end
          end # InstanceMethods
        end # Translate
      end # ActiveRecord
    end # Orm
  end # Contrib
end # Padrino
::ActiveRecord::Base.extend(Padrino::Contrib::Orm::ActiveRecord::Translate::ClassMethods)
