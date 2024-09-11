module Relaton
  module Model
    class Docidentifier < Lutaml::Model::Serializable
      include LocalizedString

      model ::Relaton::Bib::Docidentifier

      attribute :type, Lutaml::Model::Type::String
      attribute :content, Lutaml::Model::Type::String
      attribute :scope, Lutaml::Model::Type::String
      attribute :primary, Lutaml::Model::Type::Boolean

      mappings[:xml].instance_eval do
        root "docidentifier" # , mixed: true
        map_attribute "type", to: :type
        map_attribute "scope", to: :scope
        map_attribute "primary", to: :primary
      end
    end
  end
end
