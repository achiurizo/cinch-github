# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cinch/plugins/github/version"

Gem::Specification.new do |s|
  s.name        = "cinch-github"
  s.version     = Cinch::Plugins::Github::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Arthur Chiu"]
  s.email       = ["mr.arthur.chiu@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/cinch-github"
  s.summary     = %q{Github Plugin for Cinch}
  s.description = %q{Cinch Plugin to let bots interact with Github}

  s.rubyforge_project = "cinch-github"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency  'cinch', '~>1.1.1'
  s.add_dependency  'octopi'
  s.add_development_dependency 'riot', '~>0.12.0'
  s.add_development_dependency 'mocha'
end
