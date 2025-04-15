module Relaton
  module Bib
    module BibXML
      class SeriesInfo < Lutaml::Model::Serialize
        attribute :ascii_name, :string
        attribute :ascii_value, :string
        attribute :name, :string, values: %w[RFC Internat-Draft DOI]
        attribute :status, :string
        attribute :stream, :string, values: %w[IETF IAB IRTF independent]
        attribute :value, :string

        xml do
          root "seriesInfo"
          map_attribute "asciiName", to: :ascii_name
          map_attribute "asciiValue", to: :ascii_value
          map_attribute "name", to: :name
          map_attribute "status", to: :status
          map_attribute "stream", to: :stream
          map_attribute "value", to: :value
        end
      end
    end
  end
end
