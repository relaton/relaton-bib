module RelatonBib
  class StructuredIdentifierCollection
    include RelatonBib
    extend Forwardable

    def_delegators :@collection, :any?, :size, :[]

    # @param collection [Array<RelatonBib::StructuredIdentifier>]
    def initialize(collection)
      @collection = collection
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      @collection.each { |si| si.to_xml builder }
    end

    # @return [Array<Hash>]
    def to_hash
      single_element_array @collection
    end

    # @return [RelatonBib::StructuredIdentifierCollection]
    # def map(&block)
    #   StructuredIdentifierCollection.new @collection.map &block
    # end
  end

  class StructuredIdentifier
    include RelatonBib

    # @return [String]
    attr_reader :docnumber

    # @return [Array<String>]
    attr_reader :agency

    # @return [String, NilClass]
    attr_reader :type, :klass, :partnumber, :edition, :version, :supplementtype,
                :supplementnumber, :language, :year

    # rubocop:disable Metrics/MethodLength

    # @param type [String, NilClass]
    # @param agency [Array<String>]
    # @parma class [Stirng, NilClass]
    # @parma docnumber [String]
    # @param partnumber [String, NilClass]
    # @param edition [String, NilClass]
    # @param version [String, NilClass]
    # @param supplementtype [String, NilClass]
    # @param supplementnumber [String, NilClass]
    # @param language [String, NilClass]
    # @param year [String, NilClass]
    def initialize(docnumber:, **args)
      @type = args[:type]
      @agency = args[:agency]
      @klass = args[:class]
      @docnumber = docnumber
      @partnumber = args[:partnumber]
      @edition = args[:edition]
      @version = args[:version]
      @supplementtype = args[:supplementtype]
      @supplementnumber = args[:supplementnumber]
      @language = args[:language]
      @year = args[:year]
    end

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      xml = builder.structuredidentifier do |b|
        agency&.each { |a| b.agency a }
        b.class_ klass if klass
        b.docnumber docnumber
        b.partnumber partnumber if partnumber
        b.edition edition if edition
        b.version version if version
        b.supplementtype supplementtype if supplementtype
        b.supplementnumber supplementnumber if supplementnumber
        b.language language if language
        b.year year if year
      end
      xml[:type] = type if type
    end

    # @return [Hash]
    def to_hash
      hash = { "docnumber" => docnumber }
      hash["type"] = type if type
      hash["agency"] = single_element_array agency if agency&.any?
      hash["class"] = klass if klass
      hash["partnumber"] = partnumber if partnumber
      hash["edition"] = edition if edition
      hash["version"] = version if version
      hash["supplementtype"] = supplementtype if supplementtype
      hash["supplementnumber"] = supplementnumber if supplementnumber
      hash["language"] = language if language
      hash["year"] = year if year
      hash
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  end
end
