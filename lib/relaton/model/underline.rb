module Relaton
  module Model
    class Underline < Lutaml::Model::Serializable
      include PureTextElement::Mapper

      attribute :style, Lutaml::Model::Type::String

      mappings[:xml].instance_eval do
        root "underline"
        map_attribute "style", to: :style
      end
    end
  end
end
