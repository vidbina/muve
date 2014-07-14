lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'muve/version'

Gem::Specification.new do |s|
  s.name          = 'Muve'
  s.version       = Muve::VERSION
  s.summary       = 'Muve gem'
  s.description   = 'Basic helpers to be used with Muvement'
  s.authors       = ["David Asabina"]
  s.email         = ["david@supr.nu"]
  s.files         = ['lib/muve.rb']
  s.homepage      = ''
  s.license       = 'MIT'

  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler", "~> 1.6"
  s.add_development_dependency "rake"
end
