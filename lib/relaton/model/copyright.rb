module Relaton
  module Model
    class Copyright < Lutaml::Model::Serializable
      model Bib::Copyright

      attribute :from, :string
      attribute :to, :string
      attribute :owner, ContributionInfo, collection: true
      attribute :scope, :string

      xml do
        root "copyright"

        map_element "from", to: :from
        map_element "to", to: :to
        map_element "owner", to: :owner
        map_element "scope", to: :scope
      end
    end
  end
end
