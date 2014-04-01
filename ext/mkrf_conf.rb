require 'rubygems/dependency_installer.rb'

installer = Gem::DependencyInstaller.new
begin
  if RUBY_PLATFORM == 'java'
    installer.install "jruby-win32ole"
  else 
    installer.install "win32screenshot"
  end

  rescue
    exit(1)
end  

f = File.open(File.join(File.dirname(__FILE__), "Rakefile"), "w")
f.write("task :default\n")
f.close
