lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'buildlogparser/version'

Gem::Specification.new do |spec|
  spec.name          = "buildlogparser"
  spec.version       = BuildLogParser::VERSION::STRING
  spec.authors       = ["Mario Werner"]
  spec.email         = ["mario.werner@iaik.tugraz.at"]
  spec.summary       = "Parser for the extraction of information from build and execution logs."
  spec.homepage      = "https://github.com/niosHD/buildlogparser.git"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.bindir        = "bin"

  spec.add_development_dependency "minitest", "~> 5.8"
  spec.add_development_dependency "rake", "~> 10.5"
  spec.add_runtime_dependency "parslet", "~> 1.8"
end