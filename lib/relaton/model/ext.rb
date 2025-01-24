require_relative "ics"
require_relative "structured_identifier"

module Relaton
  module Model
    class Ext < Lutaml::Model::Serializable
      model Bib::Ext

      attribute :ics, ICS, collection: true
      attribute :structuredidentifier, StructuredIdentifier, collection: true

      xml do
        root "ext"
        map_element "ics", to: :ics
        map_element "structuredidentifier", to: :structuredidentifier
      end
    end
  end
end
