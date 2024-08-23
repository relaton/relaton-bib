module Relaton
  module Model
    module OrganizationType
      class Name < Lutaml::Model::Serializable
        class Primary < Lutaml::Model::Serializable
          include Model::LocalizedString

          mappings[:xml].instance_eval do
            root "primary"
          end
        end

        module Variant
          def self.included(base)
            base.instance_eval do
              attribute :primary, Primary
            end

            mappings[:xml].instance_eval do
              map_content to: :primary, using: { from: :primary_from_xml, to: :primary_to_xml }
            end
          end

          def primary_from_xml(model, node)
            model.primary = Primary.of_xml node.instance_variable_get(:@node) || node
          end

          def primary_to_xml(model, parent, _doc)
            model.primary.add_to_xml parent
          end
        end

        include Model::LocalizedString
        include Variant

        mappings[:xml].instance_eval do
          root "name"
        end
      end

      class Identifier < Lutaml::Model::Serializable
        attribute :type, Lutaml::Model::Type::String
        attribute :content, Lutaml::Model::Type::String

        xml do
          root "identifier"
          map_attribute "type", to: :type
          map_content to: :content
        end
      end

      def self.included(base) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        base.instance_eval do
          attribute :name, Name, collection: true
          attribute :subdivision, Subdivision, collection: true
          attribute :abbreviation, Abbreviation
          attribute :url, Uri, collection: true
          attribute :identifier, Identifier, collection: true
          attribute :contact, Contact, collection: true
          attribute :logo, Logo

          xml do
            map_element "name", to: :name
            map_element "subdivision", to: :subdivision
            map_element "abbreviation", to: :abbreviation
            map_element "url", to: :url
            map_element "identifier", to: :identifier
            map_element "contact", to: :contact
            map_element "logo", to: :logo
          end
        end
      end
    end
  end
end
