module RelatonBib
  # Document identifier.
  class DocumentIdentifier
    # @return [String]
    attr_reader :id

    # @return [String, NilClass]
    attr_reader :type

    # @param id [String]
    # @param type [String, NilClass]
    def initialize(id:, type: nil)
      @id   = id
      @type = type
    end

    #
    # Add docidentifier xml element
    #
    # @param [Nokogiri::XML::Builder] builder
    #
    def to_xml(builder)
      builder.docidentifier(id, type: type)
    end
  end
end