module Relaton
  module Model
    module ErefType
      class Content
        def initialize(elements = [])
          @elements = elements
        end

        def self.cast(value)
          value
        end

        def self.of_xml(node)
          elms = node.children.map { |n| PureTextElement.of_xml n }.compact
          new elms
        end

        def to_xml(parent, _doc)
          @elements.each do |element|
            element.add_to_xml parent, _doc
          end
        end
      end

      def self.included(base) # rubocop:disable Metrics/MethodLength
        base.class_eval do
          include CitationType

          attribute :normative, Shale::Type::Boolean
          attribute :citeas, Shale::Type::String
          attribute :type, Shale::Type::String
          attribute :alt, Shale::Type::String
          attribute :content, Content

          @xml_mapping.instance_eval do
            map_attribute "normative", to: :normative
            map_attribute "citeas", to: :citeas
            map_attribute "type", to: :type
            map_attribute "alt", to: :alt
            map_content to: :content, using: { from: :content_from_xml, to: :content_to_xml }
          end
        end
      end

      def content_from_xml(model, node)
        super if defined? super
        model.content = Content.of_xml node.instance_variable_get(:@node) || node
      end

      def content_to_xml(model, parent, doc)
        model.content.to_xml parent, doc
      end
    end
  end
end
