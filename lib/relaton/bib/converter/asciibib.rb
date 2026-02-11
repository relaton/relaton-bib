require_relative "asciibib/to_asciibib"

module Relaton
  module Bib
    module Converter
      module Asciibib
        def self.from_item(item)
          ToAsciibib.new(item).transform
        end
      end
    end
  end
end
