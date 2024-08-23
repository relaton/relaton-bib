module Relaton
  module Model
    module FullNameType
      class Abbreviation < Lutaml::Model::Serializable
        include LocalizedString

        mappings[:xml].instance_eval do
          root "abbreviation"
        end
      end

      class Prefix < Lutaml::Model::Serializable
        include LocalizedString

        mappings[:xml].instance_eval do
          root "prefix"
        end
      end

      class Completename < Lutaml::Model::Serializable
        include LocalizedString

        mappings[:xml].instance_eval do
          root "completename"
        end
      end

      class Forename < Lutaml::Model::Serializable
        include LocalizedString

        attribute :initial, Lutaml::Model::Type::String

        mappings[:xml].instance_eval do
          root "forename"
          map_attribute "initial", to: :initial
        end
      end

      class FormattedInitials < Lutaml::Model::Serializable
        include LocalizedString

        mappings[:xml].instance_eval do
          root "formatted-initials"
        end
      end

      class Surname < Lutaml::Model::Serializable
        include LocalizedString

        mappings[:xml].instance_eval do
          root "surname"
        end
      end

      class Addition < Lutaml::Model::Serializable
        include LocalizedString

        mappings[:xml].instance_eval do
          root "addition"
        end
      end

      def self.included(base) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        base.instance_eval do
          attribute :abbreviation, Abbreviation
          attribute :prefix, Prefix, collection: true
          attribute :forename, Forename, collection: true
          attribute :formatted_initials, FormattedInitials
          attribute :surname, Surname
          attribute :addition, Addition, collection: true
          attribute :completename, Completename
          attribute :note, Biblionote, collection: true
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

      def content_from_xml(model, node)
        model.content = Content.of_xml node.instance_variable_get(:@node) || node
      end

      def content_to_xml(model, parent, _doc)
        model.content.add_to_xml parent
      end
    end

    module FullNameType
      class Variant < Lutaml::Model::Serializable
        include FullNameType

        attribute :type, Lutaml::Model::Type::String

        mappings[:xml].instance_eval do
          root "variant"
          map_attribute "type", to: :type
        end
      end
    end
  end
end
