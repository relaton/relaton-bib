module Relaton
  module Model
    module LocalizedMarketUpString
      class Variants
        def initialize(elements = [])
          @elements = elements
        end

        def self.of_xml(node)
          elms = node.xpath("variant").map do |n|
            Variant.of_xml n
          end
          return if elms.empty?

          new elms
        end

        def add_to_xml(parent)
          @elements.each { |e| e.add_to_xml parent }
        end
      end

      class Content
        # @param elements [Array<TextElement>, Variants]
        def initialize(elements = [])
          @elements = elements
        end

        def self.cast(value)
          value
        end

        def self.of_xml(node)
          elms = Variants.of_xml node
          return elms if elms

          elms = node.children.map do |n|
            TextElement.of_xml n
          end
          new elms
        end

        def add_to_xml(parent)
          @elements.map { |e| e.add_to_xml parent }
        end
      end

      def self.included(base)
        base.class_eval do
          include Model::LocalizedStringAttrs

          attribute :content, Content

          @xml_mapping.instance_eval do
            map_content to: :content, using: { from: :content_from_xml, to: :content_to_xml }
          end
        end
      end

      def content_from_xml(model, node)
        model.content = Content.of_xml node.instance_variable_get(:@node) || node
      end

      def content_to_xml(model, parent, _doc)
        model.content.add_to_xml parent
      end

      class Variant < Shale::Mapper
        include Relaton::Model::LocalizedMarketUpString

        @xml_mapping.instance_eval do
          root "variant"
        end

        def add_to_xml(parent)
          parent << to_xml
        end
      end
    end
  end
end
