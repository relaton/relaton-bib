module Relaton
  module Model
    module IndexMapper
      class Content < Shale::Mapper
        include Relaton::Model::PureTextElement::Mapper
      end

      def self.included(base) # rubocop:disable Metrics/MethodLength
        base.class_eval do
          attribute :primary, Content
          attribute :secondary, Content
          attribute :tertiary, Content

          xml do
            map_element "primary", to: :primary
            map_element "secondary", to: :secondary
            map_element "tertiary", to: :tertiary
          end
        end
      end

      def add_to_xml(parent)
        parent << to_xml
      end
    end

    class Index < Shale::Mapper
      include IndexMapper

      attribute :to, Shale::Type::String

      @xml_mapping.instance_eval do
        root "index"
        map_attribute "to", to: :to
      end
    end
  end
end
