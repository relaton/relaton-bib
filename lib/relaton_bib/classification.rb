module RelatonBib
  class << self
    def classification_hash_to_bib(ret)
      #ret[:classification] = [ret[:classification]] unless ret[:classification].is_a?(Array)
      #ret[:classification]&.each_with_index do |c, i|
      #ret[:classification][i] = RelatonBib::Classification.new(c)
      #end
      ret[:classification] and
        ret[:classification] = Classification.new(ret[:classification])
    end
  end

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
