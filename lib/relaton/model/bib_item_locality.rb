module Relaton
  module Model
    class ReferenceFrom < Shale::Mapper
      attribute :content, Shale::Type::String

      xml do
        root "referenceFrom"
        map_content to: :content
      end
    end

    class ReferenceTo < Shale::Mapper
      attribute :content, Shale::Type::String

      xml do
        root "referenceTo"
        map_content to: :content
      end
    end

    module BibItemLocality
      def self.included(base)
        base.class_eval do
          attribute :type, Shale::Type::String
          attribute :reference_from, ReferenceFrom
          attribute :reference_to, ReferenceTo

          xml do
            map_attribute "type", to: :type
            map_element "referenceFrom", to: :reference_from
            map_element "referenceTo", to: :reference_to
          end
        end
      end
    end
  end
end
