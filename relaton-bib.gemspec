lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "relaton_bib/version"

Gem::Specification.new do |spec|
  spec.name          = "relaton-bib"
  spec.version       = RelatonBib::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "RelatonBib: Ruby XMLDOC impementation."
  spec.description   = "RelatonBib: Ruby XMLDOC impementation."
  spec.homepage      = "https://github.com/relaton/relaton-bib"
  spec.license       = "BSD-2-Clause"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  spec.add_dependency "addressable"
  spec.add_dependency "bibtex-ruby"
  spec.add_dependency "htmlentities"
  spec.add_dependency "iso639"
  spec.add_dependency "nokogiri", "~> 1.18.3"
  spec.add_dependency "relaton-logger", "~> 0.2.0"
end
