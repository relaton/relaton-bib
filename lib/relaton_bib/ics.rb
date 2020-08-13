module RelatonBib
  class ICS
    # @return [String]
    attr_reader :code, :text

    # @param code [String]
    # @param text [String]
    def initialize(code:, text:)
      @code = code
      @text = text
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.ics do |b|
        b.code code
        b.text_ text
      end
    end

    # @return [Hash]
    def to_hash
      { "code" => code, "text" => text }
    end

    # @param prefix [String]
    # @param count [Integer] number of ics
    # @return [String]
    def to_asciibib(prefix = "", count = 1)
      pref = prefix.empty? ? "ics" : prefix + ".ics"
      out = count > 1 ? "#{pref}::\n" : ""
      out += "#{pref}.code:: #{code}\n"
      out += "#{pref}.text:: #{text}\n"
      out
    end
  end
end
