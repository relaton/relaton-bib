module Relaton
  module Model
    class Affiliation < Shale::Mapper
      attribute :name, AffiliationName
      attribute :description, AffiliationDescription
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
