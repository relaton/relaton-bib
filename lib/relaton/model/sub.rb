module Relaton
  module Model
    class Sub < Shale::Mapper
      class Content
        def initialize(element)
          @element = element
        end

        def self.cast(value)
          value
        end

        def self.of_xml(node)
          case node.name
          when "text"
            text = node.text.strip
            text.empty? ? nil : new(text)
          when "em" then new Em.of_xml(node)
          when "strong" then new Strong.of_xml(node)
          end
        end

        def to_xml(parent, doc)
          if @element.is_a? String
            doc.add_text(parent, @element)
          else
            parent << @element.to_xml
          end
        end
      end

      attribute :content, PureTextElement, collection: true

      xml do
        map_content to: :content, using: { from: :content_from_xml, to: :content_to_xml }
      end

      def content_from_xml(model, node)
        model.content << PureTextElement.of_xml(node.instance_variable_get(:@node) || node)
      end

      def content_to_xml(model, parent, doc)
        model.content.each { |e| e.to_xml parent, doc }
      end
    end
  end
end
