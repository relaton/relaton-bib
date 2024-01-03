module RelatonBib
  class DocumentType
    attr_reader :type, :abbreviation

    #
    # Initialize a DocumentType.
    #
    # @param [String] type document type
    # @param [String, nil] abbreviation type abbreviation
    #
    def initialize(type:, abbreviation: nil)
      @type = type
      @abbreviation = abbreviation
    end

    #
    # Build XML representation of the document type.
    #
    # @param [Nokogiri::XML::Builder] builder XML builder
    #
    def to_xml(builder)
      xml = builder.doctype @type
      xml[:abbreviation] = @abbreviation if @abbreviation
    end

    #
    # Hash representation of the document type.
    #
    # @return [Hash]
    #
    def to_hash
      hash = { "type" => @type }
      hash["abbreviation"] = @abbreviation if @abbreviation
      hash
    end

    #
    # Asciibib representation of the document type.
    #
    # @param [String] prefix prefix
    #
    # @return [String] AsciiBib representation
    #
    def to_asciibib(prefix = "")
      pref = prefix.empty? ? prefix : "#{prefix}."
      pref += "doctype."
      out = "#{pref}type:: #{@type}\n"
      out += "#{pref}abbreviation:: #{@abbreviation}\n" if @abbreviation
      out
    end
  end
end
