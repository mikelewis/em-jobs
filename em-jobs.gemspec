# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "em-jobs/version"

Gem::Specification.new do |s|
  s.name        = "em-jobs"
  s.version     = EventMachine::Jobs::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Mike Lewis"]
  s.email       = ["ft.mikelewis@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "em-jobs"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  %w{eventmachine}.each do |depedency|
    s.add_dependency(depedency)
  end

  %w{rake rspec}.each do |development_depedency|
    s.add_development_dependency(development_depedency)
  end
end
