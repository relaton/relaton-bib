module Relaton
  module Model
    class Formattedref < Lutaml::Model::Serializable
      # include TextElement::Mapper

      model Bib::Formattedref

      attribute :content, Lutaml::Model::Type::String

      @xml_mapping.instance_eval do
        root "formattedref"
        map_content to: "content"
      end
    end
  end
end
