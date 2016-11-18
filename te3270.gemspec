# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'te3270/version'

Gem::Specification.new do |spec|
  spec.name          = "te3270"
  spec.version       = TE3270::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = ["Jeffrey S. Morgan", "Nithin C. Reddy", "Glenn W. Waters", "Thrivikrama Madiraju", "David West", "Jonathan Flatt"]
  spec.email         = ["jeff.morgan@leandog.com","nithinreddyc@gmail.com", "gwwaters@gmail.com", "akmadiraju@yahoo.com", "david.b.west@gmail.com", "c-flattj@grangeinsurance.com"]
  spec.description   = %q{Automates a 3270 Terminal Emulator}
  spec.summary       = %q{Automates a 3270 Terminal Emulator}
  spec.homepage      = "http://github.com/cheezy/te3270"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.extensions    = ["ext/mkrf_conf.rb"]

  spec.add_dependency 'page_navigation', '>= 0.9'
  spec.add_dependency 'watir-webdriver', '0.6.10'
  spec.add_dependency 'selenium-webdriver', '~>2.35.0'
  spec.add_dependency 'win32screenshot' if Gem.win_platform?

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end

