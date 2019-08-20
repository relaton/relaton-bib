# frozen_string_literal: true

require "relaton_bib/contributor"

module RelatonBib
  # module OrgIdentifierType
  #   ORCID = 'orcid'
  #   URI   = 'uri'
  # end

  # Organization identifier.
  class OrgIdentifier
    ORCID = "orcid"
    URI   = "uri"

    # @return [String]
    attr_reader :type

    # @return [String]
    attr_reader :value

    # @param type [String] "orcid" or "uri"
    # @param value [String]
    def initialize(type, value)
      unless [ORCID, URI].include? type
        raise ArgumentError, 'Invalid type. It should be "orsid" or "uri".'
      end

      @type  = type
      @value = value
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.identifier(value, type: type)
    end

    # @return [Hash]
    def to_hash
      { "type" => type, "id" => value }
    end
  end

  # Organization.
  class Organization < Contributor
    # @return [Array<RelatonBib::LocalizedString>]
    attr_reader :name

    # @return [RelatonBib::LocalizedString, NilClass]
    attr_reader :abbreviation

    # @return [RelatonBib::LocalizedString, NilClass]
    attr_reader :subdivision

    # @return [Array<RelatonBib::OrgIdentifier>]
    attr_reader :identifier

    # @param name [String, Hash, Array<String, Hash>]
    # @param abbreviation [RelatoBib::LocalizedString, String]
    # @param subdivision [RelatoBib::LocalizedString, String]
    # @param url [String]
    # @param identifier [Array<RelatonBib::OrgIdentifier>]
    # @param contact [Array<RelatonBib::Address, RelatonBib::Contact>]
    def initialize(**args)
      raise ArgumentError, "missing keyword: name" unless args[:name]

      super(url: args[:url], contact: args.fetch(:contact, []))

      @name = if args[:name].is_a?(Array)
                args[:name].map { |n| localized_string(n) }
              else
                [localized_string(args[:name])]
              end

      @abbreviation = localized_string args[:abbreviation]
      @subdivision  = localized_string args[:subdivision]
      @identifier   = args.fetch(:identifier, [])
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.organization do
        name.each do |n|
          builder.name { |b| n.to_xml b }
        end
        builder.subdivision { |s| subdivision.to_xml s } if subdivision
        builder.abbreviation { |a| abbreviation.to_xml a } if abbreviation
        builder.uri url if uri
        identifier.each { |identifier| identifier.to_xml builder }
        super
      end
    end

    # @return [Hash]
    def to_hash
      hash = { "name" => single_element_array(name) }
      hash["abbreviation"] = abbreviation.to_hash if abbreviation
      hash["identifier"] = single_element_array(identifier) if identifier&.any?
      hash["subdivision"] = subdivision.to_hash if subdivision
      { "organization" => hash.merge(super) }
    end

    private

    # @param arg [String, Hash, RelatoBib::LocalizedString]
    # @return [RelatoBib::LocalizedString]
    def localized_string(arg)
      if arg.is_a?(String) then LocalizedString.new(arg)
      elsif arg.is_a?(Hash)
        LocalizedString.new(arg[:content], arg[:language], arg[:script])
      elsif arg.is_a? LocalizedString then arg
      end
    end
  end
end
