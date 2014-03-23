# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'and_feathers/version'

Gem::Specification.new do |spec|
  spec.name          = "and_feathers"
  spec.version       = AndFeathers::VERSION
  spec.authors       = ["Brian Cobb"]
  spec.email         = ["bcobb@uwalumni.com"]
  spec.description   = %q{Declaratively and iteratively build archive structures which easily serialize to on-disk formats such as zip and tgz.}
  spec.summary       = %q{In-memory archive structures}
  spec.homepage      = "http://github.com/bcobb/and_feathers"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
