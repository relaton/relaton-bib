# frozen_string_literal: true

require "uri"

module RelatonBib
  class << self
    def affiliation_hash_to_bib(c)
      Array(c[:affiliation]).map do |a|
        a[:description] = Array(a[:description]).map do |d|
          RelatonBib::FormattedString.new(d.nil? ? { content: nil } :
            { content: d[:content], language: d[:language],
             script: d[:language], format: d[:format] })
        end
        RelatonBib::Affilation.new(
          RelatonBib::Organization.new(org_hash_to_bib(a[:organization])),
          a[:description])
      end
    end

    def contacts_hash_to_bib(c)
      Array(c[:contacts]).map do |a|
        (a[:city] || a[:country]) ?
          RelatonBib::Address.new(
            street: Array(a[:street]), city: a[:city], postcode: a[:postcode],
            country: a[:country], state: a[:state]) :
        RelatonBib::Contact.new(type: a[:type], value: a[:value])
      end
    end
  end

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
  end

  # Affilation.
  class Affilation
    # @return [RelatonBib::LocalizedString]
    attr_reader :name

    # @return [Array<RelatonBib::FormattedString>]
    attr_reader :description

    # @return [RelatonBib::Organization]
    attr_reader :organization

    # @param organization [RelatonBib::Organization]
    # @param description [Array<RelatonBib::FormattedString>]
    def initialize(organization, description = [])
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
  end

  # Contributor.
  class Contributor
    # @return [URI]
    attr_reader :uri

    # @return [Array<RelatonBib::Address, RelatonBib::Phone>]
    attr_reader :contacts

    # @param url [String]
    # @param contacts [Array<RelatonBib::Address, RelatonBib::Phone>]
    def initialize(url: nil, contacts: [])
      @uri = URI url if url
      @contacts = contacts
    end

    # Returns url.
    # @return [String]
    def url
      @uri.to_s
    end

    # @params builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      contacts.each { |contact| contact.to_xml builder }
    end
  end
end
