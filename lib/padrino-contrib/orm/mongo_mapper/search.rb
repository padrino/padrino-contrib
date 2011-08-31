module Padrino
  module Contrib
    module Orm
      module MongoMapper
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
              @_search_fields = fields
            end

            def search(text, options={})
              if text
                re    = Regexp.new(Regexp.escape(text), 'i')
                where = @_search_fields.map { |field| "this.#{field}.match(#{re.inspect})" }.join(" || ")
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
::MongoMapper::Document.send(:include, Padrino::Contrib::Orm::MongoMapper::Search)
