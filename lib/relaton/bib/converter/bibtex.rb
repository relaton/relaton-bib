require_relative "bibtex/from_bibtex"
require_relative "bibtex/to_bibtex"

module Relaton
  module Bib
    module Converter
      module Bibtex
        # ItemData -> BibTeX::Bibliography
        def self.from_item(item, bibtex = nil)
          ToBibtex.new(item).transform(bibtex)
        end

        # BibTeX string -> Hash{String=>ItemData}
        def self.to_item(bibtex_str)
          BibTeX.parse(bibtex_str).reduce({}) do |h, bt|
            h[bt.key] = FromBibtex.new(bt).transform
            h
          end
        end
      end
    end
  end
end
