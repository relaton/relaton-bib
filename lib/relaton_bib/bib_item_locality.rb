module RelatonBib
  # Bibliographic item locality.
  class BibItemLocality
    # @return [String]
    attr_reader :type

    # @return [String]
    attr_reader :reference_from

    # @return [String, NilClass]
    attr_reader :reference_to

    # @param type [String]
    # @param referenceFrom [String]
    # @param referenceTo [String, NilClass]
    def initialize(type, reference_from, reference_to = nil)
      type_ptrn = %r{section|clause|part|paragraph|chapter|page|whole|table|
        annex|figure|note|list|example|volume|issue|time|
        locality:[a-zA-Z0-9_]+}x
      unless type =~ type_ptrn
        warn "[relaton-bib] WARNING: invalid locality type: #{type}"
      end

      @type           = type
      @reference_from = reference_from
      @reference_to   = reference_to
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.parent[:type] = type
      builder.referenceFrom reference_from # { reference_from.to_xml(builder) }
      builder.referenceTo reference_to if reference_to
    end

    # @return [Hash]
    def to_hash
      hash = { "type" => type, "reference_from" => reference_from }
      hash["reference_to"] = reference_to if reference_to
      hash
    end
  end

  class Locality < BibItemLocality
    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.locality { |b| super(b) }
    end

    # @return [Hash]
    # def to_hash
    #   { "locality" => locality.to_hash }
    # end
  end

  class LocalityStack
    include RelatonBib

    # @return [Array<RelatonBib::Locality>]
    attr_reader :locality

    # @param locality [Array<RelatonBib::Locality>]
    def initialize(locality)
      @locality = locality
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.localityStack do |b|
        locality.each { |l| l.to_xml(b) }
      end
    end

    # @returnt [Hash]
    def to_hash
      { "locality_stack" => single_element_array(locality) }
    end
  end
end
