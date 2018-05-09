# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'buildlogparser/version'

Gem::Specification.new do |spec|
  spec.name          = "buildlogparser"
  spec.version       = BuildLogParser::VERSION::STRING
  spec.authors       = ["Mario Werner"]
  spec.email         = ["nioshd@gmail.com"]
  spec.summary       = "Collection of various parsers for the extraction of information from build and execution logs."
  spec.homepage      = "https://github.com/niosHD/buildlogparser"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.bindir        = "bin"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "codecov", "~> 0.1.10"
  spec.add_development_dependency "minitest", "~> 5.8"
  spec.add_development_dependency "rake", "~> 10.5"
  spec.add_development_dependency "simplecov", "~> 0.14"
  spec.add_runtime_dependency "parslet", "~> 1.8"
  spec.add_runtime_dependency "trollop", "~> 2.1"
  spec.add_runtime_dependency "terminal-table", "~> 1.8"
end
