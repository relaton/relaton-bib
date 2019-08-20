module RelatonBib
  class BiblioNote < FormattedString
    # @return [String, NilClass]
    attr_reader :type

    # @param content [String]
    # @param type [String, NilClass]
    # @param language [String, NilClass] language code Iso639
    # @param script [String, NilClass] script code Iso15924
    # @param format [String, NilClass] the content format
    def initialize(content:, type: nil, language: nil, script: nil, format: nil)
      @type = type
      super content: content, language: language, script: script, format: format
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      xml = builder.note { super }
      xml[:type] = type if type
      xml
    end

    # @return [Hash]
    def to_hash
      hash = super
      return hash unless type

      hash = { "content" => hash } if hash.is_a? String
      hash["type"] = type
      hash
    end
  end
end
