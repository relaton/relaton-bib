module Relaton
  module Bib
    # This class represents the data of a bibliographic item.
    # It needed to keep data fot different types of representations (bibitem, bibdata ...).
    # @TODO: remove this class when Lutaml Model will support transformation between different types of models.
    class ItemData
      attr_accessor :id, :type, :schema_version, :fetched, :formattedref, :title,
                    :source, :docidentifier, :docnumber, :date, :contributor,
                    :edition, :version, :note, :language, :locale, :script,
                    :abstract, :status, :copyright, :relation, :series, :medium,
                    :place, :price, :extent, :size, :accesslocation, :license,
                    :classification, :keyword, :validity, :depiction, :ext
    end
  end
end
