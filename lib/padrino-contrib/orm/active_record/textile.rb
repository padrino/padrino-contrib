require 'RedCloth'

module Padrino
  module Contrib
    module Orm
      module ActiveRecord
        ##
        # This module generate html from textile.
        #
        # In your ActiveRecord class you need only to add:
        #
        #   has_textile :body, :internal_links => :page
        #
        # In your body you can write (like github) internal links:
        #
        #   [[Page Name|link me]]
        #
        module Textile
          module ClassMethods
            def has_textile(*fields)
              include InstanceMethods
              options = fields.extract_options!
              options.reverse_merge!(:internal_links => :blog)
              @_textile_fields  = fields
              @_textile_options = options
              before_save :generate_textile
            end

            def textile_fields
              @_textile_fields
            end

            def textile_options
              @_textile_options
            end
          end

          module InstanceMethods
            protected
              def generate_textile
                self.class.textile_fields.each do |textile_field|
                  next if read_attribute(textile_field).blank?
                  html = RedCloth.new(read_attribute(textile_field)).to_html
                  # Parse internal links
                  html.gsub!(/\[\[([^\]]+)\]\]/) do
                    page, name = *$1.split("|") # this allow to rename link ex: [[Page Name|link me]]
                    name ||= page
                    "<a href=\"/#{@_textile_options[:internal_links]}/#{Post.permalink_for(page.strip)}\">#{name.strip}</a>"
                  end
                  # Write content
                  self.send("#{textile_field}_html=", html)
                end
              end
          end # InstanceMethods
        end # Permalink
      end # Ar
    end # Orm
  end # Contrib
end # Padrino
::ActiveRecord::Base.extend(Padrino::Contrib::Orm::ActiveRecord::Textile::ClassMethods)
