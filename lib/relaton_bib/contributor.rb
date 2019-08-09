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
      hash[:street] = street if street&.any?
      hash[:city] = city
      hash[:state] = state if state
      hash[:country] = country
      hash[:postcode] = postcode if postcode
      hash
    end
  end

  # Contact class.
  class Contact
    # @return [String] allowed "phone", "email" or "uri"
    attr_reader :type

    # @return [String]
    attr_reader :value

    # @param phone [String]
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
      { type: type, value: value }
    end
  end

  # Affilation.
  class Affilation
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

    # @params builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.affiliation do
        builder.name { name.to_xml builder } if name
        description.each { |d| builder.description { d.to_xml builder } }
        organization.to_xml builder
      end
    end

    # @return [Hash]
    def to_hash
      hash = organization.to_hash
      hash[:name] = name.to_hash if name
      hash[:description] = description.map(&:to_hash) if description&.any?
      hash
    end
  end

  # Contributor.
  class Contributor
    # @return [URI]
    attr_reader :uri

    # @return [Array<RelatonBib::Address, RelatonBib::Contact>]
    attr_reader :contact

    # @param url [String]
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
      hash[:url] = uri.to_s if uri
      hash[:contact] = contact.map(&:to_hash) if contact&.any?
      hash
    end
  end
end
