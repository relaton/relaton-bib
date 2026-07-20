require "relaton/logger"
require "forwardable"
# require "htmlentities"
require "bibtex"
require "iso639"
require "rfcxml"
require "relaton/core"
require_relative "bib/version"
require_relative "bib/util"
require_relative "bib/sanitizer"
require_relative "bib/namespace_helper"
# Model and converter classes are wired via autoload (see model_autoload.rb) so
# that load order is irrelevant and mutually-referencing classes resolve lazily.
require_relative "bib/model_autoload"
require_relative "bib/item_data"

module Relaton
  # class Error < StandardError; end

  class RequestError < StandardError; end

  class << self
    #
    # Read schema versions from file
    #
    # @return [Hash{String=>String}] schema versions
    #
    def schema_versions
      @@schema_versions ||= JSON.parse File.read(File.join(__dir__, "bib/versions.json"))
    end
  end

  module Bib
    def self.grammar_hash
      # gem_path = File.expand_path "..", __dir__
      # grammars_path = File.join gem_path, "grammars", "*"
      # grammars = Dir[grammars_path].sort.map { |gp| File.read gp }.join
      Digest::MD5.hexdigest Relaton::Bib::VERSION # grammars
    end
  end
end
