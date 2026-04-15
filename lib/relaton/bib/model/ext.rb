require_relative "doctype"
require_relative "ics"
require_relative "structured_identifier"

module Relaton
  module Bib
    class Ext < Lutaml::Model::Serializable
      attribute :schema_version, :string, method: :get_schema_version
      attribute :doctype, Doctype
      attribute :subdoctype, :string
      attribute :flavor, :string
      attribute :ics, ICS, collection: true, initialize_empty: true
      attribute :structuredidentifier, StructuredIdentifier, collection: true, initialize_empty: true

      xml do
        root "ext"
        map_attribute "schema-version", to: :schema_version, render_default: true
        map_element "doctype", to: :doctype
        map_element "subdoctype", to: :subdoctype
        map_element "flavor", to: :flavor
        map_element "ics", to: :ics
        map_element "structuredidentifier", to: :structuredidentifier
      end

      # Base returns nil so direct use omits schema-version. Subclasses in
      # downstream relaton gems override to return their own version.
      def get_schema_version = nil
    end
  end
end
