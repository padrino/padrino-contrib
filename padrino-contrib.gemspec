require File.expand_path("../lib/padrino-contrib/version.rb", __FILE__)

Gem::Specification.new do |s|
  s.name = "padrino-contrib"
  s.rubyforge_project = "padrino-contrib"
  s.authors = ["Padrino Team", "Nathan Esquenazi", "Davide D'Agostino", "Arthur Chiu"]
  s.email = "padrinorb@gmail.com"
  s.summary = "Contributed plugins and utilities for Padrino Framework"
  s.homepage = "http://www.padrinorb.com"
  s.description = "Contributed plugins and utilities for the Padrino Ruby Web Framework"
  s.required_rubygems_version = ">= 1.3.6"
  s.version = Padrino::Contrib.version
  s.date = Time.now.strftime("%Y-%m-%d")
  s.extra_rdoc_files = Dir["*.rdoc"]
  s.files = %w(LICENSE README.rdoc Rakefile padrino-contrib.gemspec) + Dir.glob("{bin,lib,test}/**/*")
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_path = "lib"
end