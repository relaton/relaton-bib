module Relaton
  module Model
    module PureTextElement # < Lutaml::Model::Serializable
      def self.included(base)
        base.class_eval do
          attribute :text, :string
          attribute :sup, :string
          attribute :sub, :string
          attribute :em, :string
        end
      end

      # xml do
      #   root "pure-text-element", mixed: true
      #   map_content to: :text
      #   map_element "sup", to: :sup
      #   map_element "sub", to: :sub
      # end

      # def initialize(element)
      #   @element = element
      # end

      # def self.cast(value)
      #   value
      # end

      # def self.of_xml(node, **_args) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/AbcSize,Metrics/MethodLength
      #   shale_node = Shale::Adapter::Nokogiri::Node.new node
      #   case node.name
      #   when "text"
      #     text = node.text.strip
      #     text.empty? ? nil : new(text)
      #   when "em" then new Em.of_xml(shale_node)
      #   when "strong" then new Strong.of_xml(shale_node)
      #   when "sub" then new Sub.of_xml(shale_node)
      #   when "sup" then new Sup.of_xml(shale_node)
      #   when "tt" then new Tt.of_xml(shale_node)
      #   when "underline" then new Underline.of_xml(shale_node)
      #   when "strike" then new Strike.of_xml(shale_node)
      #   when "smallcap" then new Smallcap.of_xml(shale_node)
      #   when "br" then new Br.of_xml(shale_node)
      #   end
      # end

      # def add_to_xml(parent)
      #   parent << (@element.is_a?(String) ? @element : @element.to_xml)
      # end

      # module Mapper
      #   def self.included(base)
      #     base.class_eval do
      #       attribute :content, PureTextElement, collection: true

      #       xml do
      #         map_content to: :content, using: { from: :content_from_xml, to: :content_to_xml }
      #       end
      #     end
      #   end

      #   def content_from_xml(model, node)
      #     (node.instance_variable_get(:@node) || node).children.each do |n|
      #       next if n.text? && n.text.strip.empty?

      #       model.content << PureTextElement.of_xml(n)
      #     end
      #   end

      #   def content_to_xml(model, parent, _doc)
      #     model.content.each { |e| e.add_to_xml parent }
      #   end

      #   def add_to_xml(parent)
      #     parent << to_xml
      #   end
      # end
    end
  end
end
