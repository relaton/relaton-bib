require "lutaml/model"
require 'lutaml/model/xml_adapter/nokogiri_adapter'
require_relative "nested_text_element"
require_relative "em"
require_relative "strong"
require_relative "text_element"
require_relative "localized_string_attrs"
require_relative "localized_string"
require_relative "source"
require_relative "date"
require_relative "bib_item_locality"
require_relative "locality"
require_relative "locality_stack"
require_relative "image"
require_relative "typed_title_string"
require_relative "title"
require_relative "formattedref"
require_relative "docidentifier"
require_relative "biblionote"
require_relative "full_name_type"
require_relative "fullname"
require_relative "affiliation"
require_relative "contact"
require_relative "person"
require_relative "contribution_info"
require_relative "role"
require_relative "contributor"

Lutaml::Model::Config.configure do |config|
  config.xml_adapter = Lutaml::Model::XmlAdapter::NokogiriAdapter
end

module Relaton
  module Model
    module BibliographicItem
      def self.included(base) # rubocop:disable Metrics/MethodLength
        base.class_eval do
          attribute :type, :string
          attribute :schema_version, :string
          attribute :fetched, :date
          attribute :formattedref, Formattedref
          attribute :title, Title, collection: true
          attribute :source, Source, collection: true
          attribute :docidentifier, Docidentifier, collection: true
          attribute :docnumber, :string
          attribute :date, Date, collection: true

          xml do
            map_attribute "type", to: :type
            map_attribute "schema-version", to: :schema_version
            map_attribute "fetched", to: :fetched
            map_element "formattedref", to: :formattedref
            map_element "title", to: :title, with: { from: :title_from_xml, to: :title_to_xml }
            map_element "uri", to: :source
            map_element "docidentifier", to: :docidentifier
            map_element "docnumber", to: :docnumber
            map_element "date", to: :date
          end

          def title_from_xml(model, node)
            model.title << Title.of_xml(node)
          end

          def title_to_xml(model, parent, _doc)
            model.title.each do |title|
              parent << Title.to_xml(title)
            end
          end
        end
      end
    end
  end
end
