module Relaton
  module Model
    class DocIdentifier < Lutaml::Model::Serializable
      include LocalizedMarkedUpString

      model Bib::Docidentifier

      attribute :type, Lutaml::Model::Type::String
      attribute :scope, Lutaml::Model::Type::String
      attribute :primary, Lutaml::Model::Type::Boolean

      @xml_mapping.instance_eval do
        root "docidentifier"
        map_attribute "type", to: :type
        map_attribute "scope", to: :scope
        map_attribute "primary", to: :primary
      end
    end
  end
end
