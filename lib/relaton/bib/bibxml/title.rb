module Relaton
  module Bib
    module BibXML
      class Title < Lutaml::Model::Serialize
        attribute :abbrev, :string
        attribute :ascii, :string
        attribute :content, :string

        xml do
          map_attribute "abbrev", to: :abbrev
          map_attribute "ascii", to: :ascii
          map_content to: :content
        end
      end
    end
  end
end
