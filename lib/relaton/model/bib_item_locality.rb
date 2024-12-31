module Relaton
  module Model
    # class ReferenceFrom < Lutaml::Model::Serializable
    #   attribute :content, :string

    #   xml do
    #     root "referenceFrom"
    #     map_content to: :content
    #   end
    # end

    # class ReferenceTo < Lutaml::Model::Serializable
    #   attribute :content, :string

    #   xml do
    #     root "referenceTo"
    #     map_content to: :content
    #   end
    # end

    module BibItemLocality
      def self.included(base)
        base.class_eval do
          attribute :type, :string
          attribute :reference_from, :string
          attribute :reference_to, :string

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
