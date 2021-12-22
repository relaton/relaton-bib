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

    # @param opts [Hash]
    # @option opts [Nokogiri::XML::Builder] :builder XML builder
    # @option opts [String] :lang language
    def to_xml(**opts) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      opts[:builder].name do |builder|
        if completename
          builder.completename { completename.to_xml builder }
        else
          pref = prefix.select { |p| p.language&.include? opts[:lang] }
          pref = prefix unless pref.any?
          pref.each { |p| builder.prefix { p.to_xml builder } }
          frnm = forename.select { |f| f.language&.include? opts[:lang] }
          frnm = forename unless frnm.any?
          frnm.each { |f| builder.forename { f.to_xml builder } }
          init = initial.select { |i| i.language&.include? opts[:lang] }
          init = initial unless init.any?
          init.each { |i| builder.initial { i.to_xml builder } }
          builder.surname { surname.to_xml builder }
          addn = addition.select { |a| a.language&.include? opts[:lang] }
          addn = addition unless addn.any?
          addn.each { |a| builder.addition { a.to_xml builder } }
        end
      end
    end

    # @return [Hash]
    def to_hash # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      hash = {}
      hash["forename"] = single_element_array(forename) if forename&.any?
      hash["initial"] = single_element_array(initial) if initial&.any?
      hash["surname"] = surname.to_hash if surname
      hash["addition"] = single_element_array(addition) if addition&.any?
      hash["prefix"] = single_element_array(prefix) if prefix&.any?
      hash["completename"] = completename.to_hash if completename
      hash
    end

    # @param pref [String]
    # @return [String]
    def to_asciibib(pref) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
      prf = pref.empty? ? pref : pref + "."
      prf += "name."
      out = forename.map do |fn|
        fn.to_asciibib "#{prf}forename", forename.size
      end.join
      initial.each { |i| out += i.to_asciibib "#{prf}initial", initial.size }
      out += surname.to_asciibib "#{prf}surname" if surname
      addition.each do |ad|
        out += ad.to_asciibib "#{prf}addition", addition.size
      end
      prefix.each { |pr| out += pr.to_asciibib "#{prf}prefix", prefix.size }
      out += completename.to_asciibib "#{prf}completename" if completename
      out
    end
  end

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
