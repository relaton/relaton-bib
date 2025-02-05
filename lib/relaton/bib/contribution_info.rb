module Relaton
  module Bib
    class ContributionInfo < Lutaml::Model::Serializable
      attribute :person, Person
      attribute :organization, Organization

      xml do
        map_element "person", to: :person
        map_element "organization", to: :organization
      end
    end
  end
end
