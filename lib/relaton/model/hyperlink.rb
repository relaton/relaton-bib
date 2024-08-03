module Relaton
  module Model
    class Hyperlink < Lutaml::Model::Serializable
      include PureTextElement::Mapper

      attribute :target, Lutaml::Model::Type::String
      attribute :type, Lutaml::Model::Type::String
      attribute :alt, Lutaml::Model::Type::String

      @xml_mapping.instance_eval do
        root "link"

        map_attribute "target", to: :target
        map_attribute "type", to: :type
        map_attribute "alt", to: :alt
      end
    end
  end
end
