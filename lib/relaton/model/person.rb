module Relaton
  module Model
    class Person < Shale::Mapper
      # class Name < Shale::Mapper
      #   attribute :content, Shale::Type::String

      #   xml do
      #     root "name"
      #     map_content to: :content
      #   end
      # end

      class Credential < Shale::Mapper
        attribute :content, Shale::Type::String

        xml do
          root "credential"
          map_content to: :content
        end
      end

      class Identifier < Shale::Mapper
        attribute :type, Shale::Type::String
        attribute :content, Shale::Type::String

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
