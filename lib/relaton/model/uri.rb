module Relaton
  module Model
    class Uri < Lutaml::Model::Serializable
      # model Relaton::Bib::Uri

      attribute :type, Lutaml::Model::Type::String
      attribute :content, Lutaml::Model::Type::String

      xml do
        map_attribute "type", to: :type
        map_content to: :content
      end
    end
  end
end
