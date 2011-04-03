require 'open-uri'

module Padrino
  module Contrib
    module Helpers
      ##
      # This extension joins and compress with yui-compressor your css/js files.
      #
      # ==== Usage
      #
      #   # in your app.rb
      #   use Padrino::Contrib::Helpers::AssetsCompressor
      #
      #   # in yours layouts/views
      #   =stylesheet_link_tag "grid", "base", "fancybox", "gallery", :cache => "bundle/lipsiasample"
      #   =javascript_include_tag "jquery", "gallery", "fancybox", "base", :cache => "bundle/lipsiasample"
      #   =stylesheet_link_tag "grid", "base", "fancybox", "gallery", :cache => true
      #   =javascript_include_tag "jquery", "gallery", "fancybox", "base", :cache => true
      #
      module AssetsCompressor
        def self.registered(app)
          raise "You need to add in your Gemfile: gem 'yui-compressor', :require => 'yui/compressor'" unless defined?(YUI)
          app.helpers Padrino::Contrib::Helpers::AssetsCompressor::Helpers
        end

        module Helpers
          def self.included(base)
            base.alias_method_chain :javascript_include_tag, :compression
            base.alias_method_chain :stylesheet_link_tag, :compression
          end

          def javascript_include_tag_with_compression(*sources)
            javascript_include_tag_without_compression(*assets_compressor(:js, sources))
          end

          def stylesheet_link_tag_with_compression(*sources)
            stylesheet_link_tag_without_compression(*assets_compressor(:css, sources))
          end

          def assets_compressor(kind, sources)
            began_at = Time.now
            asset_folder, compressor = *case kind
              # 8000 for line break is more browser and texmate friendly
              when :css then ['stylesheets', YUI::CssCompressor.new(:line_break => 8000)]
              when :js  then ['javascripts', YUI::JavaScriptCompressor.new(:line_break => 8000)]
              else raise "YUI Compressor didn't support yet #{kind} compression"
            end
            options = sources.extract_options!.symbolize_keys
            bundle  = options.delete(:cache)
            return sources if bundle.nil?
            bundle  = settings.app_name if bundle.is_a?(TrueClass)
            path    = Padrino.root("public", uri_root_path(asset_folder, bundle.to_s))
            path   += ".#{kind}" unless path =~ /\.#{kind}/
            return bundle if File.exist?(path)
            sources.map! do |source|
              source = asset_path(kind, source).sub(/\?.*/, '') # Removes Timestamp
              source = source =~ /^http/ ? open(source) : File.read(Padrino.root("public", source))
              # Removes extra comments
              if cs = source =~ /\/\*\!/
                cr = source.slice(cs, source.length)
                ce = cr =~ /\*\//
                cr = source.slice(cs, ce+2)
                source.sub!(cr,'')
              end
              source
            end
            Dir.mkdir(File.dirname(path)) unless File.exist?(File.dirname(path))
            File.open(path, "w") { |f| f.write(compressor.compress(sources.join("\n"))) }
            logger.debug "Compressed (%0.2fms) %s" % [Time.now-began_at, path] if defined?(logger)
            bundle
          end
        end # Helpers
      end # AssetsCompressor
    end # Helpers
  end # Contrib
end # Padrino