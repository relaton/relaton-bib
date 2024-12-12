module RelatonBib
  # Bibliographic item locality.
  class BibItemLocality
    # @return [String]
    attr_reader :type

    # @return [String]
    attr_reader :reference_from

    # @return [String, nil]
    attr_reader :reference_to

    # @param type [String]
    # @param referenceFrom [String]
    # @param referenceTo [String, nil]
    def initialize(type, reference_from, reference_to = nil)
      type_ptrn = %r{section|clause|part|paragraph|chapter|page|title|line|
        whole|table|annex|figure|note|list|example|volume|issue|time|anchor|
        locality:[a-zA-Z0-9_]+}x
      unless type&.match? type_ptrn
        Util.warn "Invalid locality type: `#{type}`"
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

    # @param prefix [String]
    # @param count [Integeg] number of localities
    # @return [String]
    def to_asciibib(prefix = "", count = 1)
      pref = prefix.empty? ? prefix : "#{prefix}."
      out = count > 1 ? "#{prefix}::\n" : ""
      out += "#{pref}type:: #{type}\n"
      out += "#{pref}reference_from:: #{reference_from}\n"
      out += "#{pref}reference_to:: #{reference_to}\n" if reference_to
      out
    end

    #
    # Render locality as BibTeX.
    #
    # @param [BibTeX::Entry] item BibTeX entry.
    #
    def to_bibtex(item)
      case type
      when "chapter" then item.chapter = reference_from
      when "page"
        value = reference_from
        value += "--#{reference_to}" if reference_to
        item.pages = value
      when "volume" then item.volume = reference_from
      when "issue" then item.number = reference_from
      end
    end
  end

  class Locality < BibItemLocality
    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.locality { |b| super(b) }
    end

    #
    # Render locality as hash.
    #
    # @return [Hash] locality as hash.
    #
    def to_hash
      { "locality" => super }
    end

    #
    # Render locality as AsciiBib.
    #
    # @param [String] prefix prefix of locality
    # @param [Integer] count number of localities
    #
    # @return [String] AsciiBib.
    #
    def to_asciibib(prefix = "", count = 1)
      pref = prefix.empty? ? "locality" : "#{prefix}.locality"
      super(pref, count)
    end
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
      hash = Hash.new { |h, k| h[k] = [] }
      locality.each_with_object(hash) do |l, obj|
        k, v = l.to_hash.first
        obj[k] << v
      end
      { "locality_stack" => hash }
    end

    #
    # Render locality stack as AsciiBib.
    #
    # @param [String] prefix <description>
    # @param [Integer] size size of locality stack
    #
    # @return [String] AsciiBib.
    #
    def to_asciibib(prefix = "", size = 1)
      pref = prefix.empty? ? "locality_stack" : "#{prefix}.locality_stack"
      out = ""
      out << "#{pref}::\n" if size > 1
      out << locality.map { |l| l.to_asciibib(pref, locality.size) }.join
    end

    #
    # Render locality stack as BibTeX.
    #
    # @param [BibTeX::Entry] item BibTeX entry.
    #
    def to_bibtex(item)
      locality.each { |l| l.to_bibtex(item) }
    end
  end

  class SourceLocality < BibItemLocality
    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.sourceLocality { |b| super(b) }
    end
  end

  class SourceLocalityStack < LocalityStack
    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.sourceLocalityStack do |b|
        locality.each { |l| l.to_xml(b) }
      end
    end

    # @returnt [Hash]
    def to_hash
      { "source_locality_stack" => single_element_array(locality) }
    end
  end
end
