module Relaton
  module Model
    class Doctype < Lutaml::Model::Serializable
      model Bib::Doctype

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
