module Relaton
  module Model
    class Xref < Lutaml::Model::Serializable
      include Relaton::Model::PureTextElement::Mapper

      attribute :target, Lutaml::Model::Type::String
      attribute :type, Lutaml::Model::Type::String
      attribute :alt, Lutaml::Model::Type::String

      @xml_mapping.instance_eval do
        root "xref"
        map_attribute "target", to: :target
        map_attribute "type", to: :type
        map_attribute "alt", to: :alt
      end
    end
  end
end
