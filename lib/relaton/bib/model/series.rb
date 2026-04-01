require_relative "type/string_date"

module Relaton
  module Bib
    class Series < Lutaml::Model::Serializable
      attribute :type, :string, values: %w[main alt]
      attribute :formattedref, Formattedref
      attribute :title, Title, collection: (1..)
      attribute :place, Place
      attribute :organization, :string
      attribute :abbreviation, LocalizedString
      attribute :from, StringDate
      attribute :to, StringDate
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
