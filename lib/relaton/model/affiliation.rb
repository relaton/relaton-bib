module Relaton
  module Model
    class Affiliation < Lutaml::Model::Serializable
      class Name < LocalizedString
        model Bib::LocalizedString

        xml do
          root "name"
        end
      end

      class Description < LocalizedString
        model Bib::LocalizedString

        xml do
          root "description"
        end
      end

      model Bib::Affiliation

      attribute :name, Name
      attribute :description, Description, collection: true
      attribute :organization, Organization

      xml do
        root "affiliation"
        map_element "name", to: :name
        map_element "description", to: :description
        map_element "organization", to: :organization
      end
    end
  end
end
