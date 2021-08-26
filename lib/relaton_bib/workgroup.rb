module RelatonBib
  class WorkGroup
    # @return [String]
    attr_reader :name

    # @return [Integer, nil]
    attr_reader :number

    # @return [String, nil]
    attr_reader :identifier, :prefix, :type

    # @param name [String]
    # @param identifier [String, nil]
    # @param prefix [String, nil]
    # @param number [Integer, nil]
    # @param type [String, nil]
    def initialize(name:, identifier: nil, prefix: nil, number: nil, type: nil)
      @identifier = identifier
      @prefix = prefix
      @name = name
      @number = number
      @type = type
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder) # rubocop:disable Metrics/AbcSize
      builder.text name
      builder.parent[:number] = number if number
      builder.parent[:type] = type if type
      builder.parent[:identifier] = identifier if identifier
      builder.parent[:prefix] = prefix if prefix
    end

    # @return [Hash]
    def to_hash
      hash = { "name" => name }
      hash["number"] = number if number
      hash["type"] = type if type
      hash["identifier"] = identifier if identifier
      hash["prefix"] = prefix if prefix
      hash
    end

    # @param prfx [String]
    # @param count [Integer]
    # @return [String]
    def to_asciibib(prfx = "", count = 1) # rubocop:disable Metrics/CyclomaticComplexity
      pref = prfx.empty? ? prfx : "#{prfx}."
      out = count > 1 ? "#{pref}::\n" : ""
      out += "#{pref}name:: #{name}\n"
      out += "#{pref}number:: #{number}\n" if number
      out += "#{pref}type:: #{type}\n" if type
      out += "#{pref}identifier:: #{identifier}\n" if identifier
      out += "#{pref}prefix:: #{prefix}\n" if prefix
      out
    end
  end
end
