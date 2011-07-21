# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "padrino-contrib/version"

Gem::Specification.new do |s|
  s.name        = "padrino-contrib"
  s.version     = Padrino::Contrib::VERSION
  s.authors     = ["Davide D'Agostino", "Nathan Esquenazi", , "Arthur Chiu"]
  s.email       = "padrinorb@gmail.com"
  s.summary     = "Contributed plugins and utilities for Padrino Framework"
  s.homepage    = "http://www.padrinorb.com"
  s.description = "Contributed plugins and utilities for the Padrino Ruby Web Framework"

  s.rubyforge_project = "padrino-contrib"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
