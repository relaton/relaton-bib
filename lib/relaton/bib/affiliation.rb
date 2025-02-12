module Relaton
  module Bib
    class Affiliation < Lutaml::Model::Serializable
      attribute :name, LocalizedString
      attribute :description, LocalizedMarkedUpString, collection: true
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
