require 'rubygems/specification' unless defined?(Gem::Specification)
require 'rake' unless defined?(Rake)

# Runs the sh command with sudo if the rake command is run with sudo
def sudo_sh(command)
  command = `whoami`.strip! != "root" ? "sudo #{command}" : command
  sh command
end

# Returns the gem specification object for a gem
def gemspec
  @gemspec ||= begin
    ::Gem::Specification.load("padrino-contrib.gemspec")
  end
end

# Most notable functions are:
#   $ rake package # packages the gem into the pkg folder
#   $ rake install # installs the gem into system
#   $ rake release # publishes gem to rubygems

desc "Validates the gemspec"
task :gemspec do
  gemspec.validate
end

desc "Displays the current version"
task :version do
  puts "Current version: #{gemspec.version}"
end

desc "Installs the gem locally"
task :install => :package do
  sudo_sh "gem install pkg/#{gemspec.name}-#{gemspec.version}"
end

desc "Uninstalls the gem locally"
task :uninstall do
  sudo_sh "gem uninstall padrino-contrib -v #{gemspec.version}"
end

desc "Release the gem"
task :release => :package do
  # sh "gem push pkg/#{gemspec.name}-#{gemspec.version}.gem"
  # sh "rm -rf pkg"
  sh "git add . && git commit -m 'Bump to version #{gemspec.version}' && git push"
end

# rake package
begin
  require 'rake/gempackagetask'
rescue LoadError
  task(:gem) { $stderr.puts '`gem install rake` to package gems' }
else
  Rake::GemPackageTask.new(gemspec) do |pkg|
    pkg.gem_spec = gemspec
  end
  task :gem => :gemspec
end

task :package => :gemspec
task :default => :install