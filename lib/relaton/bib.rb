require "relaton/logger"
require "forwardable"
# require "htmlentities"
require "bibtex"
require "iso639"
require "rfcxml"
require "relaton/core"
require_relative "bib/version"
require_relative "bib/util"
require_relative "bib/item_data"
require_relative "bib/model/item"
require_relative "bib/model/item_base"
require_relative "bib/model/bibitem"
require_relative "bib/model/bibdata"
require_relative "bib/converter/bibxml"
require_relative "bib/converter/bibtex"
require_relative "bib/model/relation"

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
      @@schema_versions ||= JSON.parse File.read(File.join(__dir__, "../../grammars/versions.json"))
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
