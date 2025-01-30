module Relaton
  module Bib
    class Item
      attr_accessor :id, :type, :schema_version, :fetched, :formattedref, :title,
                    :source, :docidentifier, :docnumber, :date, :contributor,
                    :edition, :version, :note, :language, :locale, :script,
                    :abstract, :status, :copyright, :relation, :series, :medium,
                    :place, :price, :extent, :size, :accesslocation, :license,
                    :classification, :keyword, :validity, :depiction, :ext
    end
  end
end
