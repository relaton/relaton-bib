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
      { type: type, id: value }
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

    def hash2locstr(name)
      name.is_a?(Hash) ?
        LocalizedString.new(name[:content], name[:language], name[:script]) : 
        LocalizedString.new(name)
    end

    # @param name [String, Hash, Array<String, Hash>]
    # @param abbreviation [RelatoBib::LocalizedStrig, String]
    # @param subdivision [RelatoBib::LocalizedStrig, String]
    # @param url [String]
    # @param identifier [Array<RelatonBib::OrgIdentifier>]
    # @param contact [Array<RelatonBib::Address, RelatonBib::Contact>]
    def initialize(**args)
      raise ArgumentError, "missing keyword: name" unless args[:name]

      super(url: args[:url], contact: args.fetch(:contact, []))

      @name = if args[:name].is_a?(Array)
                args[:name].map { |n| hash2locstr(n) }
              else
                [hash2locstr(args[:name])]
              end

      @abbreviation = if args[:abbreviation].is_a?(String)
                        LocalizedString.new(args[:abbreviation])
                      else
                        args[:abbreviation]
                      end

      @subdivision  = if args[:subdivision].is_a?(String)
                        LocalizedString.new(args[:subdivision])
                      else
                        args[:subdivision]
                      end

      @identifier  = args.fetch(:identifier, [])
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
      hash = { name: name.map(&:to_hash) }
      hash[:abbreviation] = abbreviation.to_hash if abbreviation
      hash[:identifier] = identifier.map(&:to_hash) if identifier&.any?
      hash[:subdivision] = subdivision.to_hash if subdivision
      { organization: hash.merge(super) }
    end
  end
end
