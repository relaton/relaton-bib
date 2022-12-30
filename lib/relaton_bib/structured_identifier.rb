module RelatonBib
  class StructuredIdentifierCollection
    include RelatonBib
    extend Forwardable

    def_delegators :@collection, :any?, :size, :[], :detect, :map, :each,
                   :reduce

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

    # @param prefix [String]
    # @return [String]
    def to_asciibib(prefix = "")
      pref = prefix.empty? ? prefix : prefix + "."
      pref += "structured_identifier"
      @collection.reduce("") do |out, si|
        out += "#{pref}::\n" if @collection.size > 1
        out + si.to_asciibib(pref)
      end
    end

    # remoe year from docnumber
    def remove_date
      @collection.each &:remove_date
    end

    def remove_part
      @collection.each &:remove_part
    end

    def all_parts
      @collection.each &:all_parts
    end

    def presence?
      any?
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

    # @return [String, nil]
    attr_reader :type, :klass, :partnumber, :edition, :version, :supplementtype,
                :supplementnumber, :language, :year

    # rubocop:disable Metrics/MethodLength

    # @param docnumber [String]
    # @param args [Hash]
    # @option args [String, nil] :type
    # @option args [Array<String>] :agency
    # @option args [Stirng, nil] :class
    # @option args [String, nil] :partnumber
    # @option args [String, nil] :edition
    # @option args [String, nil] :version
    # @option args [String, nil] :supplementtype
    # @option args [String, nil] :supplementnumber
    # @option args [String, nil] :language
    # @option args [String, nil] :year
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

    # @param prefix [String]
    # @return [String]
    def to_asciibib(prefix) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength,Metrics/PerceivedComplexity
      out = "#{prefix}.docnumber:: #{docnumber}\n"
      agency.each { |a| out += "#{prefix}.agency:: #{a}\n" }
      out += "#{prefix}.type:: #{type}\n" if type
      out += "#{prefix}.class:: #{klass}\n" if klass
      out += "#{prefix}.partnumber:: #{partnumber}\n" if partnumber
      out += "#{prefix}.edition:: #{edition}\n" if edition
      out += "#{prefix}.version:: #{version}\n" if version
      out += "#{prefix}.supplementtype:: #{supplementtype}\n" if supplementtype
      if supplementnumber
        out += "#{prefix}.supplementnumber:: #{supplementnumber}\n"
      end
      out += "#{prefix}.language:: #{language}\n" if language
      out += "#{prefix}.year:: #{year}\n" if year
      out
    end

    def remove_date
      if @type == "Chinese Standard"
        @docnumber.sub!(/-[12]\d\d\d/, "")
      else
        @docnumber.sub!(/:[12]\d\d\d/, "")
      end
      @year = nil
    end

    # in docid manipulations, assume ISO as the default: id-part:year
    def remove_part
      @partnumber = nil
      @docnumber = @docnumber.sub(/-\d+/, "")
    end

    def all_parts
      @docnumber = @docnumber + " (all parts)"
    end
  end
end
