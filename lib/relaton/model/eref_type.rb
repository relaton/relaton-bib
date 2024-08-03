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

        def add_to_xml(parent)
          @elements.each { |element| element.add_to_xml parent }
        end
      end

      def self.included(base) # rubocop:disable Metrics/MethodLength
        base.class_eval do
          include CitationType

          attribute :normative, Lutaml::Model::Type::Boolean
          attribute :citeas, Lutaml::Model::Type::String
          attribute :type, Lutaml::Model::Type::String
          attribute :alt, Lutaml::Model::Type::String
          attribute :content, Content

          # @xml_mapping.instance_eval do
          #   map_attribute "normative", to: :normative
          #   map_attribute "citeas", to: :citeas
          #   map_attribute "type", to: :type
          #   map_attribute "alt", to: :alt
          #   map_content to: :content, using: { from: :content_from_xml, to: :content_to_xml }
          # end
        end
      end

      def content_from_xml(model, node)
        super if defined? super
        model.content = Content.of_xml node.instance_variable_get(:@node) || node
      end

      def content_to_xml(model, parent, _doc)
        model.content.add_to_xml parent
      end

      def add_to_xml(parent)
        parent << to_xml
      end
    end
  end
end
