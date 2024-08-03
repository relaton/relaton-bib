module Relaton
  module Model
    class Person < Lutaml::Model::Serializable
      # class Name < Lutaml::Model::Serializable
      #   attribute :content, Lutaml::Model::Type::String

      #   xml do
      #     root "name"
      #     map_content to: :content
      #   end
      # end

      class Credential < Lutaml::Model::Serializable
        attribute :content, Lutaml::Model::Type::String

        xml do
          root "credential"
          map_content to: :content
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

      attribute :name, FullName
      attribute :credential, Credential, collection: true
      attribute :affiliation, Affiliation, collection: true
      attribute :identifier, Identifier, collection: true
      attribute :contact, Contact, collection: true
    end
  end
end
