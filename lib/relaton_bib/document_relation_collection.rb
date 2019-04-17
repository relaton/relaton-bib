# frozen_string_literal: true

module RelatonBib
  # module DocumentRelationType
  #   PARENT        = 'parent'
  #   CHILD         = 'child'
  #   OBSOLETES     = 'obsoletes'
  #   UPDATES       = 'updates'
  #   COMPLEMENTS   = 'complements'
  #   DERIVED_FORM  = 'derivedForm'
  #   ADOPTED_FORM  = 'adoptedForm'
  #   EQUIVALENT    = 'equivalent'
  #   IDENTICAL     = 'identical'
  #   NONEQUIVALENT = 'nonequivalent'
  # end

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

    def to_xml(builder)
      builder.locality(type: type) do
        builder.referenceFrom reference_from # { reference_from.to_xml(builder) }
        builder.referenceTo reference_to if reference_to
      end
    end
  end

  # Documett relation
  class DocumentRelation
    # @return [String]
    attr_reader :type

    # @return [String]
    # attr_reader :identifier, :url

    # @return [RelatonBib::BibliographicItem]
    attr_reader :bibitem

    # @return [Array<RelatonBib::BibItemLocality>]
    attr_reader :bib_locality

    # @param type [String]
    # @param identifier [String]
    # @param url [String, NillClass] (nil)
    # @param bib_locality [Array<RelatonBib::BibItemLocality>]
    # @param bibitem [RelatonBib::BibliographicItem, NillClass] (nil)
    def initialize(type:, bibitem:, bib_locality: [])
      type = "obsoletes" if type == "Now withdrawn"
      @type         = type
      # @identifier   = identifier
      # @url          = url
      @bib_locality = bib_locality
      @bibitem      = bibitem
    end

    # rubocop:disable Metrics/MethodLength

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.relation(type: type) do
        # if bibitem.nil?
        #   builder.bibitem do
        #     builder.formattedref identifier
        #     # builder.docidentifier identifier
        #   end
        # else
        bibitem.to_xml(builder)
        # end
        bib_locality.each do |l|
          l.to_xml builder
        end
        # builder.url url
      end
    end
  end
  # rubocop:enable Metrics/MethodLength

  # Document relations collection
  class DocRelationCollection < Array
    # @param relations [Array<RelatonBib::DocumentRelation, Hash>]
    # @option relations [String] :type
    # @option relations [String] :identifier
    # @option relations [String, NIllClass] :url (nil)
    # @option relations [Array<RelatonBib::BibItemLocality>] :bib_locality
    # @option relations [RelatonBib::BibliographicItem, NillClass] :bibitem (nil)
    def initialize(relations)
      super relations.map { |r| r.is_a?(Hash) ? DocumentRelation.new(r) : r }
    end

    # @return [Array<RelatonBib::DocumentRelation>]
    def replaces
      select { |r| r.type == "replace" }
    end
  end
end
