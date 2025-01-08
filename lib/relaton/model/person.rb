module Relaton
  module Model
    class Person < Lutaml::Model::Serializable
      model Bib::Person

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

      include Contact

      attribute :name, FullName
      attribute :credential, Credential, collection: true
      attribute :affiliation, Affiliation, collection: true
      attribute :identifier, Identifier, collection: true
      # attribute :contact, Contact, collection: true

      xml do
        root "person"

        map_element "name", to: :name
        map_element "credential", to: :credential
        map_element "affiliation", to: :affiliation
        map_element "identifier", to: :identifier
        # map_element "contact", to: :contact
        map_element "address", to: :address
        map_element "phone", to: :phone
        map_element "email", to: :email
        map_element "uri", to: :uri
      end
    end
  end
end
