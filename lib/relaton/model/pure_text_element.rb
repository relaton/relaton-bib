module Relaton
  module Model
    class PureTextElement
      def initialize(element)
        @element = element
      end

      def self.cast(value)
        value
      end

      def self.of_xml(node) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/AbcSize,Metrics/MethodLength
        case node.name
        when "text"
          text = node.text.strip
          text.empty? ? nil : new(text)
        when "em" then new Em.of_xml(node)
        when "strong" then new Strong.of_xml(node)
        when "sub" then new Sub.of_xml(node)
        when "sup" then new Sup.of_xml(node)
        when "tt" then new Tt.of_xml(node)
        when "underline" then new Underline.of_xml(node)
        when "strike" then new Strike.of_xml(node)
        end
      end

      def add_to_xml(parent, doc)
        if @element.is_a? String
          doc.add_text(parent, @element)
        else
          parent << @element.to_xml
        end
      end

      module Mapper
        def self.included(base)
          base.class_eval do
            attribute :content, PureTextElement, collection: true

            xml do
              map_content to: :content, using: { from: :content_from_xml, to: :content_to_xml }
            end
          end
        end

        def content_from_xml(model, node)
          (node.instance_variable_get(:@node) || node).children.each do |n|
            next if n.text? && n.text.strip.empty?

            model.content << PureTextElement.of_xml(n)
          end
        end

        def content_to_xml(model, parent, doc)
          model.content.each do |e|
            e.add_to_xml parent, doc
          end
        end
      end
    end
  end
end
