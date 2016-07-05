# ext/mkrf_conf.rb

require 'rubygems/dependency_installer'

puts 'Determining the correct dependencies to install'
installer = Gem::DependencyInstaller.new
begin
  if RUBY_PLATFORM == 'java'
    puts "Installing jruby-win32ole because Ruby #{RUBY_PLATFORM}"
    installer.install "jruby-win32ole"
  else
    puts "Installing win32screenshot because Ruby #{RUBY_PLATFORM}"
    installer.install "win32screenshot"
  end

rescue => e
  warn "#{$0}: #{e}"
  exit!
end  

puts "Writing fake Rakefile"
# Write fake Rakefile for rake since Makefile isn't used - indicates success
File.open(File.join(File.dirname(__FILE__), 'Rakefile'), 'w') do |f|
  f.write("task :default" + $/)
end