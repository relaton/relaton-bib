module Relaton
  module Model
    class Index < Shale::Mapper
      class Content < Shale::Mapper
        include Relaton::Model::PureTextElement::Mapper
      end

      attribute :to, Shale::Type::String
      attribute :primary, Content
      attribute :secondary, Content
      attribute :tertiary, Content

      xml do
        root "index"
        map_attribute "to", to: :to
        map_element "primary", to: :primary
        map_element "secondary", to: :secondary
        map_element "tertiary", to: :tertiary
      end

      def add_to_xml(parent, _doc)
        parent << to_xml
      end
    end
  end
end
