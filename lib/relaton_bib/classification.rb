module RelatonBib
  class Classification
    # @return [String, NilClass]
    attr_reader :type

    # @return [String]
    attr_reader :value

    # @param type [String, NilClass]
    # @param value [String]
    def initialize(type: nil, value:)
      @type  = type
      @value = value
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      xml = builder.classification value
      xml[:type] = type if type
    end
  end
end