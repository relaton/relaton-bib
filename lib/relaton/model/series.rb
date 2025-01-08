module Relaton
  module Model
    class Series < Lutaml::Model::Serializable
      model Bib::Series

      attribute :type, :string, values: %w[main alt]
      attribute :formattedref, :string, raw: true
      attribute :title, Title, collection: (1..)
      attribute :place, Place
      attribute :organization, :string
      attribute :abbreviation, Abbreviation
      attribute :from, :date
      attribute :to, :date
      attribute :number, :string
      attribute :partnumber, :string
      attribute :run, :string

      xml do
        root "series"
        map_attribute "type", to: :type
        map_element "formattedref", to: :formattedref
        map_element "title", to: :title
        map_element "place", to: :place
        map_element "organization", to: :organization
        map_element "abbreviation", to: :abbreviation
        map_element "from", to: :from
        map_element "to", to: :to
        map_element "number", to: :number
        map_element "partnumber", to: :partnumber
        map_element "run", to: :run
      end
    end
  end
end
