require 'rubygems' unless defined?(Gem)
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

desc "Run complete application spec suite"
RSpec::Core::RakeTask.new("spec") do |t|
  t.skip_bundler = true
  t.pattern = './spec/**/*_spec.rb'
  t.rspec_opts = %w(-fs --color --fail-fast)
end

task :default => :spec