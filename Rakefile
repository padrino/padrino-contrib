require 'rubygems' unless defined?(Gem)
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

%w(install release).each do |task|
  Rake::Task[task].enhance do
    sh "rm -rf pkg"
  end
end

desc "Bump version on github"
task :bump do
  if `git status -s`.chomp != ""
    version  = Bundler.load_gemspec(Dir[File.expand_path('../*.gemspec', __FILE__)].first).version
    sh "git add .; git commit -a -m \"Bump to version #{version}\""
  else
    puts "\e[31mNothing to commit (working directory clean)\e[0m" 
  end
end

task :release => :bump

desc "Run complete application spec suite"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = './spec/**/*_spec.rb'
  t.rspec_opts = %w(--color --format documentation --fail-fast)
end

task :default => :spec
