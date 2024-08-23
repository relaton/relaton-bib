module Relaton
  module Model
    class Formattedref < Lutaml::Model::Serializable

      model Bib::Formattedref

      attribute :content, Lutaml::Model::Type::String

      xml do
        root "formattedref"
        map_content to: "content"
      end
    end
  end
end
