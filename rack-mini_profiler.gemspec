# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rack/mini_profiler/version"

Gem::Specification.new do |s|
  s.name        = "rack-mini_profiler"
  s.version     = Rack::MiniProfiler::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Kevin Pang"]
  s.email       = ["kpanghmc@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Rack::MiniProfiler is a piece of Rack middleware that injects profiling data into HTML pages.}
  s.description = %q{}

  s.rubyforge_project = "rack-mini_profiler"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency("uuidtools") # For GUID generation
end
