task :default => :spec

desc "starts RSpactor"
task :spec do
  system "ruby -Ilib bin/rspactor"
end

desc "generates .gemspec file"
task :gemspec => "version:read" do
  spec = Gem::Specification.new do |gem|
    gem.name = "rspactor"
    gem.summary = "RSpactor is a command line tool to automatically run your changed specs & cucumber features (much like autotest)."
    gem.description = "read summary!"
    gem.email = "guillaumegentil@gmail.com"
    gem.homepage = "http://github.com/guillaumegentil/rspactor"
    gem.authors = ["Mislav Marohnić", "Andreas Wolff", "Pelle Braendgaard", "Thibaud Guillaume-Gentil"]
    gem.has_rdoc = false
    
    gem.version = GEM_VERSION
    gem.files = FileList['Rakefile', '{bin,lib,images,spec}/**/*', 'README*', 'LICENSE*']
    gem.executables = Dir['bin/*'].map { |f| File.basename(f) }
  end
  
  spec_string = spec.to_ruby
  
  begin
    Thread.new { eval("$SAFE = 3\n#{spec_string}", binding) }.join 
  rescue
    abort "unsafe gemspec: #{$!}"
  else
    File.open("#{spec.name}.gemspec", 'w') { |file| file.write spec_string }
  end
end

task :bump => ["version:bump", :gemspec]

namespace :version do
  task :read do
    unless defined? GEM_VERSION
      GEM_VERSION = File.read("VERSION")
    end
  end
  
  task :bump => :read do
    if ENV['VERSION']
      GEM_VERSION.replace ENV['VERSION']
    else
      GEM_VERSION.sub!(/\d+$/) { |num| num.to_i + 1 }
    end
    
    File.open("VERSION", 'w') { |v| v.write GEM_VERSION }
  end
end

task :release => :bump do
  system %(git commit VERSION *.gemspec -m "release v#{GEM_VERSION}")
  system %(git tag -am "release v#{GEM_VERSION}" v#{GEM_VERSION})
end