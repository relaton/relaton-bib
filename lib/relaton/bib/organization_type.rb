module Relaton
  module Bib
    module OrganizationType
      class Identifier < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :content, :string

        xml do
          root "identifier"
          map_attribute "type", to: :type
          map_content to: :content
        end
      end

      def self.included(base) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        require_relative "subdivision"

        base.instance_eval do
          include Contact

          attribute :name, TypedLocalizedString, collection: true
          attribute :subdivision, Subdivision, collection: true
          attribute :abbreviation, LocalizedString
          attribute :identifier, Identifier, collection: true
          attribute :logo, Logo

          xml do
            map_element "name", to: :name
            map_element "subdivision", to: :subdivision
            map_element "abbreviation", to: :abbreviation
            map_element "identifier", to: :identifier
            map_element "address", to: :address
            map_element "phone", to: :phone
            map_element "email", to: :email
            map_element "uri", to: :uri
            map_element "logo", to: :logo
          end
        end
      end
    end
  end
end
