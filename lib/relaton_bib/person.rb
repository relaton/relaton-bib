# frozen_string_literal: true

require "relaton_bib/contributor"

module RelatonBib
  # Person's full name
  class FullName
    include RelatonBib

    # @return [Array<RelatonBib::LocalizedString>]
    attr_accessor :forename

    # @return [Array<RelatonBib::LocalizedString>]
    attr_accessor :initial

    # @return [RelatonBib::LocalizedString]
    attr_accessor :surname

    # @return [Array<RelatonBib::LocalizedString>]
    attr_accessor :addition

    # @return [Array<RelatonBib::LocalizedString>]
    attr_accessor :prefix

    # @return [RelatonBib::LocalizedString]
    attr_reader :completename

    # @param surname [RelatonBib::LocalizedString]
    # @param forename [Array<RelatonBib::LocalizedString>]
    # @param initial [Array<RelatonBib::LocalizedString>]
    # @param addition [Array<RelatonBib::LocalizedString>]
    # @param prefix [Array<RelatonBib::LocalizedString>]
    # @param completename [RelatonBib::LocalizedString]
    def initialize(**args)
      unless args[:surname] || args[:completename]
        raise ArgumentError, "Should be given :surname or :completename"
      end

      @surname      = args[:surname]
      @forename     = args.fetch :forename, []
      @initial      = args.fetch :initial, []
      @addition     = args.fetch :addition, []
      @prefix       = args.fetch :prefix, []
      @completename = args[:completename]
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.name do
        if completename
          builder.completename { completename.to_xml builder }
        else
          prefix.each { |p| builder.prefix { p.to_xml builder } } 
          initial.each { |i| builder.initial { i.to_xml builder } }
          addition.each { |a| builder.addition { a.to_xml builder } }
          builder.surname { surname.to_xml builder }
          forename.each { |f| builder.forename { f.to_xml builder } }
        end
      end
    end

    # @return [Hash]
    def to_hash
      hash = {}
      hash["forename"] = single_element_array(forename) if forename&.any?
      hash["initial"] = single_element_array(initial) if initial&.any?
      hash["surname"] = surname.to_hash if surname
      hash["addition"] = single_element_array(addition) if addition&.any?
      hash["prefix"] = single_element_array(prefix) if prefix&.any?
      hash["completename"] = completename.to_hash if completename
      hash
    end
  end

  # Person identifier type.
  module PersonIdentifierType
    ISNI = "isni"
    URI  = "uri"

    # Checks type.
    # @param type [String]
    # @raise [ArgumentError] if type isn't "isni" or "uri"
    def self.check(type)
      unless [ISNI, URI].include? type
        raise ArgumentError, 'Invalid type. It should be "isni" or "uri".'
      end
    end
  end

  # Person identifier.
  class PersonIdentifier
    # @return [RelatonBib::PersonIdentifierType::ISNI, RelatonBib::PersonIdentifierType::URI]
    attr_accessor :type

    # @return [String]
    attr_accessor :value

    # @param type [RelatonBib::PersonIdentifierType::ISNI, RelatonBib::PersonIdentifierType::URI]
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
  end

  # Person class.
  class Person < Contributor
    # @return [RelatonBib::FullName]
    attr_accessor :name

    # @return [Array<RelatonBib::Affilation>]
    attr_accessor :affiliation

    # @return [Array<RelatonBib::PersonIdentifier>]
    attr_accessor :identifier

    # @param name [RelatonBib::FullName]
    # @param affiliation [Array<RelatonBib::Affiliation>]
    # @param contact [Array<RelatonBib::Address, RelatonBib::Contact>]
    # @param identifier [Array<RelatonBib::PersonIdentifier>]
    def initialize(name:, affiliation: [], contact: [], identifier: [])
      super(contact: contact)
      @name        = name
      @affiliation = affiliation
      @identifier = identifier
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.person do
        name.to_xml builder
        affiliation.each { |a| a.to_xml builder }
        identifier.each { |id| id.to_xml builder }
        contact.each { |contact| contact.to_xml builder }
      end
    end

    # @return [Hash]
    def to_hash
      hash = { "name" => name.to_hash }
      hash["affiliation"] = single_element_array(affiliation) if affiliation&.any?
      hash["identifier"] = single_element_array(identifier) if identifier&.any?
      { "person" => hash.merge(super) }
    end
  end
end
