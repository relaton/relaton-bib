module Relaton
  module Model
    class Formattedref < Lutaml::Model::Serializable
      include TextElement

      model Bib::Formattedref

      attribute :content, :string

      xml do
        root "formattedref"
        map_all to: :content
      end
    end
  end
end
