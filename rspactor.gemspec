require "rake"

spec = Gem::Specification.new do |s| 
  s.name = "rspactor"
  s.version = "0.2.0"
  s.author = "Andreas Wolff"
  s.email = "treas@dynamicdudes.com"
  s.homepage = "http://rubyphunk.com"
  s.platform = Gem::Platform::RUBY
  s.summary = "RSpactor is a little command line tool to automatically run your changed specs (much like autotest)."
  s.files = FileList["{bin,lib,asset}/**/*"].to_a
  s.require_path = "lib"
  s.has_rdoc = true
  s.rubyforge_project = "rspactor"
  s.executables << 'rspactor'
  #s.add_dependency("dependency", ">= 0.x.x")
end