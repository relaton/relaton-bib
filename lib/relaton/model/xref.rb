module Relaton
  module Model
    class Xref < Shale::Mapper
      include Relaton::Model::PureTextElement::Mapper

      attribute :target, Shale::Type::String
      attribute :type, Shale::Type::String
      attribute :alt, Shale::Type::String

      @xml_mapping.instance_eval do
        root "xref"
        map_attribute "target", to: :target
        map_attribute "type", to: :type
        map_attribute "alt", to: :alt
      end
    end
  end
end
