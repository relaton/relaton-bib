module Relaton
  module Model
    class Collection
      extend Forwardable
      def_delegator :@elements, :<<

      def initialize(elements = [])
        @elements = elements
      end

      def to_xml(parent)
        @elements.map { |e| e.to_xml(parent) }.join
      end
    end

    class AnyElement
      attr_reader :name, :content

      def initialize(name, content)
        @name = name
        @content = content
      end

      def self.of_xml(node)
        elms = node.children.map do |e|
          of_node e
        end
        Collection.new elms
      end

      def self.of_node(node)
        cont = node.text? ? node.text : of_xml(node)
        new node.name, cont
      end

      def self.cast(value)
        value
      end

      def text?
        name == "text"
      end

      # @param parent [Nokogiri::XML::Element]
      def to_xml(parent)
        if text?
          parent << content
        else
          node = Nokogiri::XML::Node.new name, parent.document
          content.to_xml node
          parent.add_child node
        end
      end
    end
  end
end
