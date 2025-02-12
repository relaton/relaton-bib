module Relaton
  module Bib
    class Locality < Lutaml::Model::Serializable
      attribute :type, :string, pattern: %r{
        section|clause|part|paragraph|chapter|page|title|line|whole|table|annex|
        figure|note|list|example|volume|issue|time|anchor|locality:[a-zA-Z0-9_]+
      }x
      attribute :reference_from, :string
      attribute :reference_to, :string

      xml do
        map_attribute "type", to: :type
        map_element "referenceFrom", to: :reference_from
        map_element "referenceTo", to: :reference_to
      end
    end
  end
end
