require 'open-uri'
require 'fileutils'

module Padrino
  module Contrib
    module Helpers
      ##
      # This extension joins and compress with yui-compressor your css/js files.
      #
      # ==== Usage
      #
      #   # in your app.rb
      #   register Padrino::Contrib::Helpers::AssetsCompressor
      #
      #   # in yours layouts/views
      #   =stylesheet_link_tag "grid", "base", "fancybox", "gallery", :cache => "bundle/sample"
      #   =javascript_include_tag "jquery", "gallery", "fancybox", "base", :cache => "bundle/sample"
      #   =stylesheet_link_tag "grid", "base", "fancybox", "gallery", :cache => true
      #   =javascript_include_tag "jquery", "gallery", "fancybox", "base", :cache => true
      #
      module AssetsCompressor
        def self.registered(app, options={})
          raise "You need to add in your Gemfile: gem 'yui-compressor', :require => 'yui/compressor'" unless defined?(YUI)
          app.helpers Padrino::Contrib::Helpers::AssetsCompressor::Helpers unless app.respond_to?(:compressor)
          app.set :compressor, {}

          # Setup YUI Compressor
          options.reverse_merge!(:line_break => 8000)
          app.compressor[:css] = YUI::CssCompressor.new(options)
          app.compressor[:js]  = YUI::JavaScriptCompressor.new(options)
        end

        module Helpers
          def self.included(base)
            base.alias_method_chain :javascript_include_tag, :compression
            base.alias_method_chain :stylesheet_link_tag, :compression
            base.alias_method_chain :asset_path, :compression
          end

          def javascript_include_tag_with_compression(*sources)
            javascript_include_tag_without_compression(*assets_compressor(:js, sources))
          end

          def stylesheet_link_tag_with_compression(*sources)
            stylesheet_link_tag_without_compression(*assets_compressor(:css, sources))
          end

          def cache_asset(file, options={}, &block)
            began_at  = Time.now
            kind      = File.extname(file).sub(/\./, '').to_sym
            original  = Dir[File.join(settings.views, file).sub(/#{kind}$/, "*")][0]
            mtime     = File.mtime(original).to_i
            file      = file.sub(/#{kind}$/, "#{mtime}.#{kind}")
            path      = Padrino.root("public", uri_root_path(file))

            if !File.exist?(path)
              source = block.call

              if options[:compress]
                source = settings.compressor[kind].compress(source)
              end

              Dir.mkdir(File.dirname(path)) unless File.exist?(File.dirname(path))
              File.open(path, "w") { |f| f.write(source) }
              logger.debug "Compressed (%0.2fms) %s" % [Time.now-began_at, path] if defined?(logger)
            end

            redirect file
          end

          def assets_compressor(kind, sources)
            options = sources.extract_options!.symbolize_keys
            bundle  = options.delete(:cache)
            return sources if bundle.nil?

            began_at = Time.now
            asset_folder = case kind
              when :css then 'stylesheets'
              when :js  then 'javascripts'
              else raise "YUI Compressor didn't support yet #{kind} compression"
            end

            bundle  = settings.app_name.downcase if bundle.is_a?(TrueClass)
            path    = Padrino.root("public", uri_root_path(asset_folder, bundle.to_s))

            # Detect changes
            stamps = sources.inject(0) do |memo, source|
              asset_path_without_compression(kind, source) =~ /\?(\d{10})$/
              memo += $1.to_i
              memo
            end

            bundle  = "#{bundle}.#{stamps}" if stamps > 0
            path    = Padrino.root("public", uri_root_path(asset_folder, bundle.to_s))
            path   += ".#{kind}" unless path =~ /\.#{kind}/

            # Back if no changes happens
            return bundle if File.exist?(path)

            # Clean old cached files
            Dir[path.gsub(/\.\d{10}\.#{kind}/, "*")].each { |file| FileUtils.rm_f(file) }

            # Get source code
            errors = []
            code = sources.map do |source|
              source = asset_path(kind, source).sub(/\?\d{10}$/, '') # Removes Timestamp
              begin
                source = source =~ /^http/ ? open(source) : File.read(Padrino.root("public", source))
              rescue Exception => e
                logger.error e.message
                errors << source
                next
              end
              # Removes extra comments
              if cs = source =~ /\/\*\!/
                cr = source.slice(cs, source.length)
                ce = cr =~ /\*\//
                cr = source.slice(cs, ce+2)
                source.sub!(cr,'')
              end
              source.each_line.reject { |l| l.strip == "" }.join
            end

            # Write the new bundled file
            Dir.mkdir(File.dirname(path)) unless File.exist?(File.dirname(path))
            File.open(path, "w") { |f| f.write(settings.compressor[kind].compress(code.join("\n"))) }
            logger.debug "Compressed (%0.2fms) %s" % [Time.now-began_at, path] if defined?(logger)

            # Return the updated bundle
            errors.unshift bundle
          end

          def asset_path_with_compression(kind, source)
            file = asset_path_without_compression(kind, source)
            find_last_modified(file)
          end

          private
            def find_last_modified(file)
              file_was, file = file, file.sub(/\?\d+$/, '')
              return file unless File.exist?(file)
              path  = Padrino.root("public", uri_root_path(file))
              path  = path.sub(/\.\d{10}\./, '').sub(/#{File.extname(file)}$/, '')
              found = Dir[path+"*"].sort[-1]
              found ? found.sub(/^.*public/, '') : file_was
            end
        end # Helpers
      end # AssetsCompressor
    end # Helpers
  end # Contrib
end # Padrino
