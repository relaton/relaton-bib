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
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  spec.add_development_dependency "byebug"
  spec.add_development_dependency "equivalent-xml", "~> 0.6"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "rubocop-rails"
  spec.add_development_dependency "ruby-jing"
  spec.add_development_dependency "simplecov"

  spec.add_dependency "addressable"
  spec.add_dependency "bibtex-ruby"
  spec.add_dependency "iso639"
  spec.add_dependency "nokogiri", "~> 1.13.0"
end
