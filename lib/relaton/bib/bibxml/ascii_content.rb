module Relaton
  module Bib
    module BibXML
      class AsciiContent < Lutaml::Model::Serialize
        attribute :ascii, :string
        attribute :content, :string

        xml do
          map_attribute "ascii", to: :ascii
          map_content to: :content
        end
      end
    end
  end
end
