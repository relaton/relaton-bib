module Relaton
  module Bib
    # Shared attribute and XML mapping declarations for Item/Bibitem/Bibdata/ItemBase.
    # Each class composes these with its own header (id/schema_version/fetched/ext)
    # via instance_exec, so subtractive monkey-patching of inherited mappings is
    # not needed.
    module ItemShared
      ATTRIBUTES = lambda do # rubocop:disable Metrics/BlockLength
        attribute :type, :string, values: %W[
          article book booklet manual proceedings presentation thesis techreport standard
          unpublished map electronic\sresource audiovisual film video boradcast software
          graphic_work music patent inbook incollection inproceedings journal website
          webresource dataset archival social_media alert message convesation misc
        ]
        attribute :formattedref, Formattedref
        attribute :title, Title, collection: true, initialize_empty: true
        attribute :source, Uri, collection: true, initialize_empty: true
        attribute :docidentifier, Docidentifier, collection: true, initialize_empty: true
        attribute :docnumber, :string
        attribute :date, Date, collection: true, initialize_empty: true
        attribute :contributor, Contributor, collection: true, initialize_empty: true
        attribute :edition, Edition
        attribute :version, Version, collection: true, initialize_empty: true
        attribute :note, Note, collection: true, initialize_empty: true
        attribute :language, :string, collection: true, initialize_empty: true
        attribute :locale, :string, collection: true, initialize_empty: true
        attribute :script, :string, collection: true, initialize_empty: true
        attribute :abstract, Abstract, collection: true, initialize_empty: true
        attribute :status, Status
        attribute :copyright, Copyright, collection: true, initialize_empty: true
        attribute :relation, Relation, collection: true, initialize_empty: true
        attribute :series, Series, collection: true, initialize_empty: true
        attribute :medium, Medium
        attribute :place, Place, collection: true, initialize_empty: true
        attribute :price, Price, collection: true, initialize_empty: true
        attribute :extent, Extent, collection: true, initialize_empty: true
        attribute :size, Size
        attribute :accesslocation, :string, collection: true, initialize_empty: true
        attribute :license, :string, collection: true, initialize_empty: true
        attribute :classification, Docidentifier, collection: true, initialize_empty: true
        attribute :keyword, Keyword, collection: true, initialize_empty: true
        attribute :validity, Validity
        attribute :depiction, Depiction, collection: true, initialize_empty: true
      end

      XML_BODY = lambda do # rubocop:disable Metrics/BlockLength
        map_element "formattedref", to: :formattedref
        map_element "title", to: :title
        map_element "uri", to: :source
        map_element "docidentifier", to: :docidentifier
        map_element "docnumber", to: :docnumber
        map_element "date", to: :date
        map_element "contributor", to: :contributor
        map_element "edition", to: :edition
        map_element "version", to: :version
        map_element "note", to: :note
        map_element "language", to: :language
        map_element "locale", to: :locale
        map_element "script", to: :script
        map_element "abstract", to: :abstract
        map_element "status", to: :status
        map_element "copyright", to: :copyright
        map_element "relation", to: :relation
        map_element "series", to: :series
        map_element "medium", to: :medium
        map_element "place", to: :place
        map_element "price", to: :price
        map_element "extent", to: :extent
        map_element "size", to: :size
        map_element "accesslocation", to: :accesslocation
        map_element "license", to: :license
        map_element "classification", to: :classification
        map_element "keyword", to: :keyword
        map_element "validity", to: :validity
        map_element "depiction", to: :depiction
      end
    end
  end
end
