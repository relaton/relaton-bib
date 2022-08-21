# frozen_string_literal: true

module RelatonBib
  # Person identifier type.
  module PersonIdentifierType
    ISNI  = "isni"
    ORCID = "orcid"
    URI   = "uri"

    # Checks type.
    # @param type [String]
    # @raise [ArgumentError] if type isn't "isni" or "uri"
    def self.check(type)
      unless [ISNI, ORCID, URI].include? type
        raise ArgumentError, 'Invalid type. It should be "isni", "orcid", "\
          "or "uri".'
      end
    end
  end

  # Person identifier.
  class PersonIdentifier
    # @return [RelatonBib::PersonIdentifierType::ISNI,
    #   RelatonBib::PersonIdentifierType::ORCID,
    #   RelatonBib::PersonIdentifierType::URI]
    attr_accessor :type

    # @return [String]
    attr_accessor :value

    # @param type [RelatonBib::PersonIdentifierType::ISNI,
    #   RelatonBib::PersonIdentifierType::ORCID,
    #   RelatonBib::PersonIdentifierType::URI]
    # @param value [String]
    def initialize(type, value)
      PersonIdentifierType.check type

      @type  = type
      @value = value
    end

    # @param builser [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.identifier value, type: type
    end

    # @return [Hash]
    def to_hash
      { "type" => type, "id" => value }
    end

    # @param prefix [String]
    # @param count [Integer] number of ids
    # @return [String]
    def to_asciibib(prefix = "", count = 1)
      pref = prefix.empty? ? prefix : prefix + "."
      out = count > 1 ? "#{prefix}::\n" : ""
      out += "#{pref}type:: #{type}\n"
      out += "#{pref}value:: #{value}\n"
      out
    end
  end

  # Person class.
  class Person < Contributor
    # @return [RelatonBib::FullName]
    attr_accessor :name

    # @return [Array<RelatonBib::Affiliation>]
    attr_accessor :affiliation

    # @return [Array<RelatonBib::PersonIdentifier>]
    attr_accessor :identifier

    # @param name [RelatonBib::FullName]
    # @param affiliation [Array<RelatonBib::Affiliation>]
    # @param contact [Array<RelatonBib::Address, RelatonBib::Contact>]
    # @param identifier [Array<RelatonBib::PersonIdentifier>]
    # @param url [String, NilClass]
    def initialize(name:, affiliation: [], contact: [], identifier: [],
                   url: nil)
      super(contact: contact, url: url)
      @name        = name
      @affiliation = affiliation
      @identifier = identifier
    end

    # @param opts [Hash]
    # @option opts [Nokogiri::XML::Builder] :builder XML builder
    # @option opts [String, Symbol] :lang language
    def to_xml(**opts)
      opts[:builder].person do |builder|
        name.to_xml(**opts)
        affiliation.each { |a| a.to_xml(**opts) }
        identifier.each { |id| id.to_xml builder }
        contact.each { |contact| contact.to_xml builder }
      end
    end

    # @return [Hash]
    def to_hash
      hash = { "name" => name.to_hash }
      if affiliation&.any?
        hash["affiliation"] = single_element_array(affiliation)
      end
      hash["identifier"] = single_element_array(identifier) if identifier&.any?
      { "person" => hash.merge(super) }
    end

    # @param prefix [String]
    # @count [Integer] number of persons
    # @return [String]
    def to_asciibib(prefix = "", count = 1) # rubocop:disable Metrics/AbcSize
      pref = prefix.sub(/\*$/, "person")
      out = count > 1 ? "#{pref}::\n" : ""
      out += name.to_asciibib pref
      affiliation.each { |af| out += af.to_asciibib pref, affiliation.size }
      identifier.each { |id| out += id.to_asciibib pref, identifier.size }
      out += super pref
      out
    end
  end
end
