module Padrino
  module Contrib
    module Helpers
      ##
      # Sample usage
      #
      # # app/app.rb
      # module Sample
      #   class App < Padrino::Application
      #     register Padrino::Contrib::Helpers::Breadcrumbs
      #
      #     helpers do
      #       def breadcrumb
      #         @breadcrumb ||= Padrino::Contrib::Helpers::Breadcrumb.new
      #       end
      #     end
      #
      #     before do
      #       breadcrumb.set_home '/', 'Index'
      #     end
      #
      #     get :index do
      #       breadcrumbs breadcrumb
      #     end
      #
      #     get :foo do
      #       breadcrumb.add :foo, "/foo", "foo page"
      #       breadcrumbs breadcrumb
      #     end
      #
      #     get :test do
      #       breadcrumb.add :test, "/test", "test page"
      #       render :test
      #     end
      #   end
      # end
      #
      # # app/views/test.slim
      # = breadcrumbs breadcrumb
      #
      class Breadcrumb
        attr_accessor :home, :items

        DEFAULT_URL = "/"
        DEFAULT_CAPTION ="Home Page"

        ##
        # Initialize breadcrumbs with default value.
        #
        # @example
        #   before do
        #     @breadcrumbs = breadcrumbs.new
        #   end
        #
        def initialize
          reset!
        end

        ##
        # Set the custom home (Parent) link.
        #
        # @param [String] url
        #  The url href.
        #
        # @param [String] caption
        #   The  text caption.
        #
        # @param [Hash] options
        #   The HTML options to include in li.
        #
        # @example
        #   breadcrumbs.set_home "/HomeFoo", "Foo Home", :id => "home-breadcrumb"
        #
        def set_home(url, caption, options = {})
          self.home = {
            :url     => url.to_s,
            :caption => caption.to_s.humanize,
            :name    => :home,
            :options => options
          }
          reset
        end

        ##
        # Reset breadcrumbs to default or personal home.
        #
        # @example
        #   breadcrumbs.reset
        #
        def reset
          self.items = []
          self.items << home
        end

        ##
        # Reset breadcrumbs to default home.
        #
        # @example
        #   breadcrumbs.reset!
        #
        def reset!
          self.home = {
            :name    => :home,
            :url     => DEFAULT_URL,
            :caption => DEFAULT_CAPTION,
            :options => {}
          }
          reset
        end

        ##
        # Add a new breadcrumbs.
        #
        # @param [String] name
        #   The name of resource.
        # @param [Symbol] name
        #   The name of resource.
        #
        # @param [String] url
        #   The url href.
        #
        # @param [String] caption
        #   The text caption.
        #
        # @param [Hash] options
        #   The HTML options to include in li.
        #
        # @example
        #   breadcrumbs.add "foo", "/foo", "Foo Link", :id => "foo-id"
        #   breadcrumbs.add :foo, "/foo", "Foo Link", :class => "foo-class"
        #
        def add(name, url, caption, options = {})
          items << {
            :name    => name.to_sym,
            :url     => url.to_s,
            :caption => caption.to_s.humanize,
            :options => options
          }
        end
        alias :<< :add

        ##
        # Remove a breadcrumb.
        #
        # @param [String] name
        #  The name of resource to delete from breadcrumbs list.
        #
        # @example
        #   breadcrumbs.del "foo"
        #   breadcrumbs.del :foo
        #
        def del(name)
          items.delete_if { |item| item[:name] == name.to_sym }
        end
      end # Breadcrumb

      module Breadcrumbs
        class << self
          ##
          # Registers the Padrino::Contrib::Breadcrumbs helpers with the application.
          #
          # @param [Sinatra::Application] app The application that needs the breadcrumbs.
          #
          # @example
          #   class Demo < Padrino::Application
          #     register Padrino::Contrib::Helpers::Breadcrumbs
          #   end
          #
          def registered(app)
            require 'padrino-contrib/helpers/breadcrumbs'
            app.helpers Padrino::Contrib::Helpers::Breadcrumbs::Helpers if app.respond_to?(:helpers)
          end
          alias_method :included, :registered
        end

        module Helpers
          ##
          # Render breadcrumbs to view.
          #
          # @param [Breadcrumbs] breadcrumbs
          #   The breadcrumbs to render into view.
          #
          # @param [Boolean] bootstrap
          #  If true, render separation (useful with Twitter Bootstrap).
          #
          # @param [String] active
          #  CSS class style set to active breadcrumb.
          #
          # @param [Hash] options
          #   The HTML options to include in ul.
          #
          # @return [String] Unordered list with breadcrumbs
          #
          # @example
          #  = breadcrumbs @breacrumbs
          #  # Generates:
          #  # <ul>
          #  #   <li><a href="/foo">Foo Link</a></li>
          #  #   <li class="active"><a href="/bar">Bar Link</a></li>
          #  # </ul>
          #
          def breadcrumbs(breadcrumbs, bootstrap = false, active = "active", options = {})
            content = ActiveSupport::SafeBuffer.new
            breadcrumbs.items[0..-2].each do |item|
              content << render_item(item, bootstrap)
            end
            last = breadcrumbs.items.last
            last_options = last[:options]
            last = link_to(last[:caption], last[:url])

            classes = [options[:class], last_options[:class]].map { |class_name| class_name.to_s.split(/\s/) }
            classes[0] << "breadcrumb"
            classes[1] << active if active
            options[:class], last_options[:class] = classes.map { |class_name| class_name * " " }

            content << content_tag(:li, last, last_options)
            content_tag(:ul, content, options)
          end

          private
          ##
          # Private method to return list item.
          #
          # @param [Hash] item
          #   The breadcrumb item.
          #
          # @param [Boolean] bootstrap
          #   If true, render separation (useful with Twitter Bootstrap).
          #
          # @return [String] List item with breadcrumb
          #
          def render_item(item, bootstrap)
            content = ActiveSupport::SafeBuffer.new
            content << link_to(item[:caption], item[:url])
            content << content_tag(:span, "/", :class => "divider") if bootstrap
            content_tag(:li, content, item[:options])
          end
        end
      end # Breadcrumbs
    end # Helpers
  end # Contrib
end # Padrino
