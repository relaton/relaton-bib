module Relaton
  module Bib
    class Doctype < Lutaml::Model::Serializable
      attribute :abbreviation, :string
      attribute :content, :string

      xml do
        root "doctype"
        map_attribute "abbreviation", to: :abbreviation
        map_content to: :content
      end
    end
  end
end
