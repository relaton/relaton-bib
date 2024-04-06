module RelatonBib
  # Address class.
  class Address
    # @return [Array<String>]
    attr_reader :street

    # @return [String, nil]
    attr_reader :city, :state, :country, :postcode, :formatted_address

    # @param street [Array<String>] streets
    # @param city [String, nil] city, should be present or formatted address provided
    # @param state [String, nil] state
    # @param country [String, nil] country, should be present or formatted address provided
    # @param postcode [String, nil] postcode
    # @param formatted_address [String, nil] formatted address, should be present or city and country provided
    def initialize(**args) # rubocop:disable Metrics/CyclomaticComplexity
      unless args[:formatted_address] || (args[:city] && args[:country])
        raise ArgumentError, "Either formatted address or city and country must be provided"
      end

      @street   = args[:street] || []
      @city     = args[:city]
      @state    = args[:state]
      @country  = args[:country]
      @postcode = args[:postcode]
      @formatted_address = args[:formatted_address] unless args[:city] && args[:country]
    end

    # @param doc [Nokogiri::XML::Document]
    def to_xml(doc) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      doc.address do
        if formatted_address
          doc.formattedAddress formatted_address
        else
          street.each { |str| doc.street str }
          doc.city city
          doc.state state if state
          doc.country country
          doc.postcode postcode if postcode
        end
      end
    end

    # @return [Hash]
    def to_hash # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      hash = { "address" => {} }
      if formatted_address
        hash["address"]["formatted_address"] = formatted_address
      else
        hash["address"]["street"] = street if street.any?
        hash["address"]["city"] = city
        hash["address"]["state"] = state if state
        hash["address"]["country"] = country
        hash["address"]["postcode"] = postcode if postcode
      end
      hash
    end

    # @param prefix [String]
    # @param count [Integer] number of addresses
    # @return [String]
    def to_asciibib(prefix = "", count = 1) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      pref = prefix.empty? ? "address" : "#{prefix}.address"
      if formatted_address
        "#{pref}.formatted_address:: #{formatted_address}\n"
      else
        out = count > 1 ? "#{pref}::\n" : ""
        street.each { |st| out += "#{pref}.street:: #{st}\n" }
        out += "#{pref}.city:: #{city}\n"
        out += "#{pref}.state:: #{state}\n" if state
        out += "#{pref}.country:: #{country}\n"
        out += "#{pref}.postcode:: #{postcode}\n" if postcode
        out
      end
    end
  end
end
