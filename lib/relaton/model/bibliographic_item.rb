require "shale"
require "shale/adapter/nokogiri"
require_relative "any_element"
require_relative "date"
require_relative "bib_item_locality"
require_relative "locality"
require_relative "locality_stack"
require_relative "citation_type"
require_relative "eref_type"
require_relative "eref"
require_relative "bsource"
require_relative "bdate"
require_relative "text_element"
require_relative "pure_text_element"
require_relative "stem"
require_relative "em"
require_relative "strong"
require_relative "sub"
require_relative "sup"
require_relative "tt"
require_relative "underline"
require_relative "strike"
require_relative "formattedref"

Shale.xml_adapter = Shale::Adapter::Nokogiri

module Relaton
  module Model
    module BibliographicItem
      def self.included(base) # rubocop:disable Metrics/MethodLength
        base.class_eval do
          attribute :type, Shale::Type::String
          attribute :schema_version, Shale::Type::String
          attribute :fetched, Shale::Type::Date
          attribute :formattedref, Formattedref

          xml do
            map_attribute "type", to: :type
            map_attribute "schema-version", to: :schema_version
            map_attribute "fetched", to: :fetched
            map_element "formattedref", to: :formattedref
          end
        end
      end
    end
  end
end
