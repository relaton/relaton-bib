module Relaton
  module Model
    class Underline < Shale::Mapper
      include PureTextElement::Mapper

      attribute :style, Shale::Type::String

      @xml_mapping.instance_eval do
        root "underline"
        map_attribute "style", to: :style
      end
    end
  end
end
