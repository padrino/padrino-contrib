module Padrino
  module Contrib
    module Orm
      module Mm
        ##
        # This module provides full text search in specified fileds with pagination support.
        #
        # == Examples
        #
        #   # model.rb
        #   has_search  :title, :body
        #
        #   # controller.rb
        #   Model.search("some thing")
        #   Model.search("some thing", :order => "position", :page => (params[:page] || 1), :draft => false, :paginate => true)
        #
        module Search
          extend ActiveSupport::Concern

          module ClassMethods
            def has_search(*fields)
              class_inheritable_accessor  :search_fields
              write_inheritable_attribute :search_fields, fields
            end

            def search(text, options={})
              if text
                re    = Regexp.new(Regexp.escape(text), 'i')
                where = search_fields.map { |field| "this.#{field}.match(#{re.inspect})" }.join(" || ")
                options.merge!("$where" => where)
              end
              options.delete(:paginate) ? paginate(options) : all(options)
            end
          end
        end # Permalink
      end # Mm
    end # Orm
  end # Contrib
end # Padrino
MongoMapper::Document.send(:include, Padrino::Contrib::Orm::Mm::Search)