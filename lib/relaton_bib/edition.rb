module RelatonBib
  class Edition
    # @return [String] edition
    attr_reader :content

    # @return [String, nil] number
    attr_reader :number

    #
    # Initialize edition.
    #
    # @param [String, Integer, Float] content edition
    # @param [String, Integer, Float, nil] number number
    #
    def initialize(content:, number: nil)
      @content = content.to_s
      @number = number&.to_s
    end

    #
    # Render edition as XML.
    #
    # @param [Nokogiri::XML::Builder] builder XML builder
    #
    def to_xml(builder)
      node = builder.edition(content)
      node[:number] = number if number
    end

    #
    # Return edition as hash.
    #
    # @return [Hash] edition as hash.
    #
    def to_hash
      hash = { "content" => content }
      hash["number"] = number if number
      hash
    end

    #
    # Render edition as AsciiBib.
    #
    # @param [String] prefix prefix
    #
    # @return [String] edition as AsciiBib.
    #
    def to_asciibib(prefix = "")
      pref = prefix.empty? ? "edition" : "#{prefix}.edition"
      out = "#{pref}.content:: #{content}\n"
      out += "#{pref}.number:: #{number}\n" if number
      out
    end
  end
end
