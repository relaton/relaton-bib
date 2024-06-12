module Relaton
  module Model
    module CitationType
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
            when "locality" then Locality.of_xml n
            when "localityStack" then LocalityStack.of_xml n
            when "date" then Date.of_xml n
            end
          end.compact
          new elms
        end

        def to_xml(parent, _doc)
          @elements.each do |element|
            parent << element.to_xml
          end
        end
      end

      class << self
        def prepended(base)
          return unless base.is_a? Class

          base.class_eval do
            attribute :bibitemid, Shale::Type::String

            xml do
              map_attribute "bibitemid", to: :bibitemid
              map_content to: :content, using: { from: :content_from_xml, to: :content_to_xml }
            end
          end
        end

        alias_method :included, :prepended
      end

      def content_from_xml(model, node)
        model.content = Content.of_xml node # .instance_variable_get(:@node)
      end

      def content_to_xml(model, parent, doc)
        model.content.to_xml parent, doc
      end
    end
  end
end
