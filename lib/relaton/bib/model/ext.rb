require_relative "doctype"
require_relative "editorial_group"
require_relative "ics"
require_relative "structured_identifier"

module Relaton
  module Bib
    class Ext < Lutaml::Model::Serializable
      attribute :schema_version, :string
      attribute :doctype, Doctype
      attribute :subdoctype, :string
      attribute :flavor, :string
      attribute :editorialgroup, EditorialGroup
      attribute :ics, ICS, collection: true
      attribute :structuredidentifier, StructuredIdentifier, collection: true

      xml do
        root "ext"
        map_attribute "schema-version", to: :schema_version
        map_element "doctype", to: :doctype
        map_element "subdoctype", to: :subdoctype
        map_element "flavor", to: :flavor
        map_element "editorialgroup", to: :editorialgroup
        map_element "ics", to: :ics
        map_element "structuredidentifier", to: :structuredidentifier
      end
    end
  end
end
