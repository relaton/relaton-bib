# frozen_string_literal: true

require "uri"

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

    def ==(other)
      street == other.street && city == other.city && state == other.state &&
        country == other.country && postcode == other.postcode &&
        formatted_address == other.formatted_address
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

    def ==(other)
      type == other.type && subtype == other.subtype && value == other.value
    end

    # @param builder [Nokogiri::XML::Document]
    def to_xml(builder)
      node = builder.send type, value
      node["type"] = subtype if subtype
    end

    # @return [Hash]
    def to_hash
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

  # Affiliation.
  class Affiliation
    include RelatonBib

    # @return [RelatonBib::LocalizedString, nil]
    attr_reader :name

    # @return [RelatonBib::Organization]
    attr_reader :organization

    # @param organization [RelatonBib::Organization, nil]
    # @param name [RelatonBib::LocalizedString, nil]
    # @param description [Array<RelatonBib::FormattedString>]
    def initialize(organization: nil, name: nil, description: [])
      @name = name
      @organization = organization
      @description  = description
    end

    def ==(other)
      name == other.name && organization == other.organization && description == other.description
    end

    # @param opts [Hash]
    # @option opts [Nokogiri::XML::Builder] :builder XML builder
    # @option opts [String] :lang language
    def to_xml(**opts)
      return unless organization || name || description&.any?

      opts[:builder].affiliation do |builder|
        name_xml builder
        description_xml builder
        organization&.to_xml(**opts)
      end
    end

    def name_xml(builder)
      builder.name { name.to_xml builder } if name
    end

    def description_xml(builder)
      description.each { |d| builder.description { d.to_xml builder } }
    end

    #
    # Get description.
    #
    # @param [String, nil] lang language if nil return all description
    #
    # @return return [Array<RelatonBib::FormattedString>] description
    #
    def description(lang = nil)
      return @description unless lang

      @description.select { |d| d.language&.include? lang }
    end

    #
    # Render affiliation as hash.
    #
    # @return [Hash]
    #
    def to_hash
      hash = organization&.to_hash || {}
      hash["name"] = name.to_hash if name
      if description&.any?
        hash["description"] = single_element_array(description)
      end
      hash
    end

    # @param prefix [String]
    # @param count [Integer]
    # @return [String]
    def to_asciibib(prefix = "", count = 1) # rubocop:disable Metrics/AbcSize
      pref = prefix.empty? ? prefix : "#{prefix}."
      out = count > 1 ? "#{pref}affiliation::\n" : ""
      out += name.to_asciibib "#{pref}affiliation.name" if name
      description.each do |d|
        out += d.to_asciibib "#{pref}affiliation.description", description.size
      end
      out += organization.to_asciibib "#{pref}affiliation.*" if organization
      out
    end
  end

  # Contributor.
  class Contributor
    include RelatonBib

    # @return [URI]
    attr_reader :uri

    # @return [Array<RelatonBib::Address, RelatonBib::Contact>]
    attr_reader :contact

    # @param url [String, nil]
    # @param contact [Array<RelatonBib::Address, RelatonBib::Contact>]
    def initialize(url: nil, contact: [])
      @uri = URI url if url
      @contact = contact
    end

    def ==(other)
      uri == other.uri && contact == other.contact
    end

    # Returns url.
    # @return [String]
    def url
      @uri.to_s
    end

    # @params builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      contact.each { |contact| contact.to_xml builder }
    end

    # @return [Hash]
    def to_hash
      hash = {}
      hash["url"] = uri.to_s if uri
      hash["contact"] = single_element_array(contact) if contact&.any?
      hash
    end

    # @param prefix [String]
    # @return [String]
    def to_asciibib(prefix = "") # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      pref = prefix.empty? ? prefix : "#{prefix}."
      out = ""
      out += "#{pref}url:: #{uri}\n" if uri
      addr = contact.select { |c| c.is_a? RelatonBib::Address }
      addr.each { |ct| out += ct.to_asciibib prefix, addr.size }
      cont = contact.select { |c| c.is_a? RelatonBib::Contact }
      cont.each { |ct| out += ct.to_asciibib prefix, cont.size }
      out
    end
  end
end
