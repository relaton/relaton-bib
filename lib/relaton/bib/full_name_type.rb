module Relaton
  module Bib
    module FullNameType
      class Forename < LocalizedString
        attribute :initial, :string

        xml do
          map_attribute "initial", to: :initial
        end
      end

      def self.included(base) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        base.instance_eval do
          attribute :abbreviation, LocalizedMarkedUpString
          attribute :prefix, LocalizedMarkedUpString, collection: true
          attribute :forename, Forename, collection: true
          attribute :formatted_initials, LocalizedMarkedUpString
          attribute :surname, LocalizedMarkedUpString
          attribute :addition, LocalizedMarkedUpString, collection: true
          attribute :completename, LocalizedMarkedUpString
          attribute :note, Note, collection: true
          attribute :variant, Variant, collection: true

          xml do
            map_element "abbreviation", to: :abbreviation
            map_element "prefix", to: :prefix
            map_element "forename", to: :forename
            map_element "formatted-initials", to: :formatted_initials
            map_element "surname", to: :surname
            map_element "addition", to: :addition
            map_element "completename", to: :completename
            map_element "note", to: :note
            map_element "variant", to: :variant
          end
        end
      end

      # def content_from_xml(model, node)
      #   model.content = Content.of_xml node.instance_variable_get(:@node) || node
      # end

      # def content_to_xml(model, parent, _doc)
      #   model.content.add_to_xml parent
      # end
    end

    module FullNameType
      class Variant < Lutaml::Model::Serializable
        include FullNameType

        attribute :type, :string

        xml do
          root "variant"
          map_attribute "type", to: :type
        end
      end
    end
  end
end
