module Padrino
  module Contrib
    module Helpers
      ##
      # Download in your public/javascript dir the latest jquery lib.
      #
      # ==== Usage:
      #
      #   javascript_include_tag_jquery :cache => :lib, :ui => true, :i18n => true
      #
      module JQuery
        def self.registered(app)
          app.helpers Helpers
        end

        module Helpers
          def stylesheet_link_tag_jquery(options={})
            theme = options.delete(:theme) || :smoothness
            version = options.delete(:version) || '1.8.16'

            stylesheet_link_tag('http://ajax.googleapis.com/ajax/libs/jqueryui/%s/themes/%s/jquery-ui.css' % [version, theme], options)
          end

          def javascript_include_tag_jquery(options={})
            libs  = ["http://ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js"]

            if options.delete(:ui)
              libs << "http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.14/jquery-ui.min.js"
            end

            if options.delete(:i18n)
              libs << "http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.6/i18n/jquery-ui-i18n.min.js"
            end

            if cache = options.delete(:cache)
              cache = 'jquery' if cache.is_a?(TrueClass)
              lib   = cache.to_s
              path  = Padrino.root("public", uri_root_path('javascripts', lib))
              path += ".js" unless path =~ /\.js$/

              unless File.exist?(path)
                began_at = Time.now
                require 'open-uri' unless defined?(OpenURI)
                sources = libs.map do |l|
                  source = open(l).read
                  # Removes extra comments
                  if cs = source =~ /\/\*\!/
                    cr = source.slice(cs, source.length)
                    ce = cr =~ /\*\//
                    cr = source.slice(cs, ce+2)
                    source.sub!(cr,'')
                  end
                  # Removes empty lines
                  source.each_line.reject { |l| l.strip == "" }.join
                end
                File.open(path, "w") { |f| f.write sources.join("\n") }
                logger.debug "JQuery Cached (%0.2fms) %s" % [Time.now-began_at, path] if defined?(logger)
              end

              libs = lib
            end

            javascript_include_tag(libs)
          end
        end # Helpers
      end # JQuery
    end # Helpers
  end # Contrib
end # Padrino
