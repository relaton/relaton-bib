module Relaton
  module Model
    class ContributionInfo < Lutaml::Model::Serializable
      model Bib::ContributionInfo

      attribute :person, Person
      attribute :organization, Organization

      xml do
        root "contributioninfo"

        map_element "person", to: :person
        map_element "organization", to: :organization
      end
    end
  end
end
