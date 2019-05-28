module RelatonBib
  class BiblioNote < FormattedString
    # @return [String]
    attr_reader :type

    # @param content [String]
    # @param type [String]
    # @param language [String] language code Iso639
    # @param script [String] script code Iso15924
    # @param format [String] the content type
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
  end
end