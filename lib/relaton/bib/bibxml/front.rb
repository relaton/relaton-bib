require_relative "title"
require_relative "series_info"
require_relative "author"

module Relaton
  module Bib
    module BibXML
      class Front < Lutaml::Model::Serialize
        attribute :title, Title
        attribute :seiesinfo, SeriesInfo, collection: true
        attribute :author, Author, collection: true
        attribute :date, BibXML::Date
        attribute :area, Area, collection: true
        attribute :workgroup, WorkGroup, collection: true
        attribute :keyword, Keyword, collection: true
        attribute :abstract, Abstract
        attribute :note, Note, collection: true
        attribute :boilerplate, Boilerplate

        xml do
          map_element "title", to: :title
          map_element "seriesInfo", to: :seiesinfo
          map_element "author", to: :author
          map_element "date", to: :date
          map_element "area", to: :area
          map_element "workgroup", to: :workgroup
          map_element "keyword", to: :keyword
          map_element "abstract", to: :abstract
          map_element "note", to: :note
          map_element "boilerplate", to: :boilerplate
        end
      end
    end
  end
end
