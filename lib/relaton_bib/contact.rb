module RelatonBib
  # Contact class.
  class Contact
    # @return [String] allowed "phone", "email" or "uri"
    attr_reader :type

    # @return [String, nil]
    attr_reader :subtype

    # @return [String]
    attr_reader :value

    # @param type [String] allowed "phone", "email" or "uri"
    # @param subtype [String, nil] i.e. "fax", "mobile", "landline" for "phone"
    #                              or "work", "personal" for "uri" type
    # @param value [String]
    def initialize(type:, value:, subtype: nil)
      @type     = type
      @subtype  = subtype
      @value    = value
    end

    # @param builder [Nokogiri::XML::Document]
    def to_xml(builder)
      node = builder.send type, value
      node["type"] = subtype if subtype
    end

    # @return [Hash]
    def to_h
      hash = { type => value }
      hash["type"] = subtype if subtype
      hash
    end

    # @param prefix [String]
    # @param count [Integer] number of contacts
    # @return [string]
    def to_asciibib(prefix = "", count = 1)
      pref = prefix.empty? ? prefix : "#{prefix}."
      out = count > 1 ? "#{pref}contact::\n" : ""
      out += "#{pref}contact.#{type}:: #{value}\n"
      out += "#{pref}contact.type:: #{subtype}\n" if subtype
      out
    end
  end
end
