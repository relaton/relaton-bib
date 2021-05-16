module RelatonBib
  class ICS
    # @return [String]
    attr_reader :code

    # @return [String, nil]
    attr_reader :text

    # @param code [String]
    # @param text [String, nil]
    def initialize(code:, text: nil)
      @code = code
      @text = text
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.ics do |b|
        b.code code
        b.text_ text if text
      end
    end

    # @return [Hash]
    def to_hash
      hash = { "code" => code }
      hash["text"] = text if text
      hash
    end

    # @param prefix [String]
    # @param count [Integer] number of ics
    # @return [String]
    def to_asciibib(prefix = "", count = 1)
      pref = prefix.empty? ? "ics" : "#{prefix}.ics"
      out = count > 1 ? "#{pref}::\n" : ""
      out += "#{pref}.code:: #{code}\n"
      out += "#{pref}.text:: #{text}\n" if text
      out
    end
  end
end
