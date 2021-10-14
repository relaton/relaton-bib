# frozen_string_literal: true

require "uri"

module RelatonBib
  # Address class.
  class Address
    # @return [Array<String>]
    attr_reader :street

    # @return [String]
    attr_reader :city

    # @return [String, NilClass]
    attr_reader :state

    # @return [String]
    attr_reader :country

    # @return [String, NilClass]
    attr_reader :postcode

    # @param street [Array<String>]
    # @param city [String]
    # @param state [String]
    # @param country [String]
    # @param postcode [String]
    def initialize(street:, city:, state: nil, country:, postcode: nil)
      @street   = street
      @city     = city
      @state    = state
      @country  = country
      @postcode = postcode
    end

    # @param builder [Nokogiri::XML::Document]
    def to_xml(doc)
      doc.address do
        street.each { |str| doc.street str }
        doc.city city
        doc.state state if state
        doc.country country
        doc.postcode postcode if postcode
      end
    end

    # @return [Hash]
    def to_hash
      hash = {}
      hash["street"] = street if street&.any?
      hash["city"] = city
      hash["state"] = state if state
      hash["country"] = country
      hash["postcode"] = postcode if postcode
      hash
    end

    # @param prefix [String]
    # @param count [Integer] number of addresses
    # @return [String]
    def to_asciibib(prefix = "", count = 1) # rubocop:disable Metrics/AbcSize
      pref = prefix.empty? ? "address" : prefix + ".address"
      out = count > 1 ? "#{pref}::\n" : ""
      street.each { |st| out += "#{pref}.street:: #{st}\n" }
      out += "#{pref}.city:: #{city}\n"
      out += "#{pref}.state:: #{state}\n" if state
      out += "#{pref}.country:: #{country}\n"
      out += "#{pref}.postcode:: #{postcode}\n" if postcode
      out
    end
  end

  # Contact class.
  class Contact
    # @return [String] allowed "phone", "email" or "uri"
    attr_reader :type

    # @return [String]
    attr_reader :value

    # @param type [String] allowed "phone", "email" or "uri"
    # @param value [String]
    def initialize(type:, value:)
      @type  = type
      @value = value
    end

    # @param builder [Nokogiri::XML::Document]
    def to_xml(doc)
      doc.send type, value
    end

    # @return [Hash]
    def to_hash
      { "type" => type, "value" => value }
    end

    # @param prefix [String]
    # @param count [Integer] number of contacts
    # @return [string]
    def to_asciibib(prefix = "", count = 1)
      pref = prefix.empty? ? prefix : prefix + "."
      out = count > 1 ? "#{pref}contact::\n" : ""
      out += "#{pref}contact.type:: #{type}\n"
      out += "#{pref}contact.value:: #{value}\n"
      out
    end
  end

  # Affiliation.
  class Affiliation
    include RelatonBib

    # @return [RelatonBib::LocalizedString, NilClass]
    attr_reader :name

    # @return [Array<RelatonBib::FormattedString>]
    attr_reader :description

    # @return [RelatonBib::Organization]
    attr_reader :organization

    # @param organization [RelatonBib::Organization]
    # @param name [RelatonBib::LocalizedString, NilClass]
    # @param description [Array<RelatonBib::FormattedString>]
    def initialize(organization:, name: nil, description: [])
      @name = name
      @organization = organization
      @description  = description
    end

    # @param opts [Hash]
    # @option opts [Nokogiri::XML::Builder] :builder XML builder
    # @option opts [String] :lang language
    def to_xml(**opts) # rubocop:disable Metrics/AbcSize
      opts[:builder].affiliation do |builder|
        builder.name { name.to_xml builder } if name
        desc = description.select { |d| d.language&.include? opts[:lang] }
        desc = description unless desc.any?
        desc.each { |d| builder.description { d.to_xml builder } }
        organization.to_xml(**opts)
      end
    end

    # @return [Hash]
    def to_hash
      hash = organization.to_hash
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
      pref = prefix.empty? ? prefix : prefix + "."
      out = count > 1 ? "#{pref}affiliation::\n" : ""
      out += name.to_asciibib "#{pref}affiliation.name" if name
      description.each do |d|
        out += d.to_asciibib "#{pref}affiliation.description", description.size
      end
      out += organization.to_asciibib "#{pref}affiliation.*"
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

    # @param url [String, NilClass]
    # @param contact [Array<RelatonBib::Address, RelatonBib::Contact>]
    def initialize(url: nil, contact: [])
      @uri = URI url if url
      @contact = contact
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
      pref = prefix.empty? ? prefix : prefix + "."
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
