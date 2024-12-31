module Relaton
  module Model
    class Person < Lutaml::Model::Serializable
      model Bib::Person

      # class Name < Lutaml::Model::Serializable
      #   attribute :content, Lutaml::Model::Type::String

      #   xml do
      #     root "name"
      #     map_content to: :content
      #   end
      # end

      class Credential < Lutaml::Model::Serializable
        attribute :content, :string

        xml do
          root "credential"
          map_content to: :content
        end
      end

      class Identifier < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :content, :string

        xml do
          root "identifier"
          map_attribute "type", to: :type
          map_content to: :content
        end
      end

      attribute :name, FullName
      attribute :credential, Credential, collection: true
      attribute :affiliation, Affiliation, collection: true
      attribute :identifier, Identifier, collection: true
      attribute :contact, Contact, collection: true

      xml do
        root "person"

        map_element "name", to: :name
        map_element "credential", to: :credential
        map_element "affiliation", to: :affiliation
        map_element "identifier", to: :identifier
        map_element "contact", to: :contact
      end
    end
  end
end
