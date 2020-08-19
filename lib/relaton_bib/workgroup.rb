module RelatonBib
  class WorkGroup
    # @return [String]
    attr_reader :content

    # @return [Integer, nil]
    attr_reader :number

    # @return [String, nil]
    attr_reader :type

    # @param content [String]
    # @param number [Integer, nil]
    # @param type [String, nil]
    def initialize(content:, number: nil, type: nil)
      @content = content
      @number = number
      @type = type
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.text content
      builder.parent[:number] = number if number
      builder.parent[:type] = type if type
    end

    # @return [Hash]
    def to_hash
      hash = { "content" => content }
      hash["number"] = number if number
      hash["type"] = type if type
      hash
    end

    # @param prefix [String]
    # @return [String]
    def to_asciibib(prefix = "")
      pref = prefix.empty? ? prefix : prefix + "."
      out = "#{pref}content:: #{content}\n"
      out += "#{pref}number:: #{number}\n" if number
      out += "#{pref}type:: #{type}\n" if type
      out
    end
  end
end
