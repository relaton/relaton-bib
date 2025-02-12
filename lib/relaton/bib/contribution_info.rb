module Relaton
  module Bib
    class ContributionInfo < Lutaml::Model::Serializable
      choice(min: 1, max: 1) do
        attribute :person, Person
        attribute :organization, Organization
      end

      xml do
        no_root
        map_element "person", to: :person
        map_element "organization", to: :organization
      end
    end
  end
end
