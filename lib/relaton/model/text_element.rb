module Relaton
  module Model
    class TextElement
      def initialize(element)
        @element = element
      end

      def self.cast(value)
        value
      end

      def self.of_xml(node) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/AbcSize,Metrics/MethodLength
        shale_node = Shale::Adapter::Nokogiri::Node.new node
        case node.name
        when "text"
          text = node.text.strip
          text.empty? ? nil : new(text)
        when "em" then new Em.of_xml(shale_node)
        when "eref" then new Eref.of_xml(shale_node)
        when "strong" then new Strong.of_xml(shale_node)
        when "stem" then new Stem.of_xml(shale_node)
        when "sub" then new Sub.of_xml(shale_node)
        when "sup" then new Sup.of_xml(shale_node)
        when "tt" then new Tt.of_xml(shale_node)
        when "underline" then new Underline.of_xml(shale_node)
        when "keyword" then new Keyword.of_xml(shale_node)
        when "ruby" then new Ruby.of_xml(shale_node)
        when "strike" then new Strike.of_xml(shale_node)
        when "smallcap" then new Smallcap.of_xml(shale_node)
        when "xref" then new Xref.of_xml(shale_node)
        when "br" then new Br.of_xml(shale_node)
        when "link" then new Hyperlink.of_xml(shale_node)
        when "hr" then new Hr.of_xml(shale_node)
        when "pagebreak" then new Pagebreak.of_xml(shale_node)
        when "bookmark" then new Bookmark.of_xml(shale_node)
        when "image" then new Image.of_xml(shale_node)
        when "index" then new Index.of_xml(shale_node)
        when "index-xref" then new IndexXref.of_xml(shale_node)
        end
      end

      def add_to_xml(parent)
        parent << (@element.is_a?(String) ? @element : @element.to_xml)
      end

      module Mapper
        def self.included(base)
          base.class_eval do
            attribute :content, TextElement, collection: true

            xml do
              map_content to: :content, using: { from: :content_from_xml, to: :content_to_xml }
            end
          end
        end

        def content_from_xml(model, node)
          (node.instance_variable_get(:@node) || node).children.each do |n|
            next if n.text? && n.text.strip.empty?

            model.content << TextElement.of_xml(n)
          end
        end

        def content_to_xml(model, parent, doc)
          model.content.each { |e| e.add_to_xml parent, doc }
        end
      end
    end
  end
end
