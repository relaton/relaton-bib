module Relaton
  module Model
    class Underline < Lutaml::Model::Serializable
      include PureTextElement::Mapper

      attribute :style, Lutaml::Model::Type::String

      @xml_mapping.instance_eval do
        root "underline"
        map_attribute "style", to: :style
      end
    end
  end
end
