module Relaton
  module Model
    class Docidentifier < Lutaml::Model::Serializable
      # include LocalizedString

      # model Bib::Docidentifier

      attribute :type, Lutaml::Model::Type::String
      attribute :scope, Lutaml::Model::Type::String
      attribute :primary, Lutaml::Model::Type::Boolean
      attribute :sup, Lutaml::Model::Type::String, collection: true

      xml do
        root "docidentifier", mixed: true
        map_element "sup", to: :sup
        map_attribute "type", to: :type
        map_attribute "scope", to: :scope
        map_attribute "primary", to: :primary
      end
    end
  end
end
