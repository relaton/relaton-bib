module RelatonBib
  # class SpecificLocalityType
  #   SECTION   = 'section'
  #   CLAUSE    = 'clause'
  #   PART      = 'part'
  #   PARAGRAPH = 'paragraph'
  #   CHAPTER   = 'chapter'
  #   PAGE      = 'page'
  #   WHOLE     = 'whole'
  #   TABLE     = 'table'
  #   ANNEX     = 'annex'
  #   FIGURE    = 'figure'
  #   NOTE      = 'note'
  #   EXAMPLE   = 'example'
  #   # generic String is allowed
  # end

  # Bibliographic item locality.
  class BibItemLocality
    # @return [RelatonBib::SpecificLocalityType]
    attr_reader :type

    # @return [RelatonBib::LocalizedString]
    attr_reader :reference_from

    # @return [RelatonBib::LocalizedString]
    attr_reader :reference_to

    # @param type [String]
    # @param referenceFrom [String]
    # @param referenceTo [String]
    def initialize(type, reference_from, reference_to = nil)
      @type           = type
      @reference_from = reference_from
      @reference_to   = reference_to
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.locality(type: type) do
        builder.referenceFrom reference_from # { reference_from.to_xml(builder) }
        builder.referenceTo reference_to if reference_to
      end
    end
  end
end