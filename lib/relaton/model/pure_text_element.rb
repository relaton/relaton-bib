module Relaton
  module Model
    module PureTextElement
      class Content
        def initialize(elements = [])
          @elements = elements
        end

        def self.cast(value)
          value
        end

        def self.of_xml(node)
          elms = node.children.map do |n|
            case n.name
            when "text"
              text = n.text.strip
              text.empty? ? nil : text
            when "em" then Em.of_xml n
            end
          end.compact
          new elms
        end

        def to_xml(parent, doc)
          @elements.each do |element|
            if element.is_a? String
              doc.add_text(parent, element)
            else
              parent << element
            end
          end
        end
      end

      # def self.included(base)
      #   base.instance_eval do
      #     attribute :content, Content
      #     attribute :em, Em

      #     xml do
      #       map_content to: :content
      #     end
      #   end
      # end
    end
  end
end
