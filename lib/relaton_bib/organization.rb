# frozen_string_literal: true

require "relaton_bib/contributor"

module RelatonBib
  class << self
    def org_hash_to_bib(c)
      return nil if c.nil?
      c[:identifiers] = array(c[:identifiers])&.map do |a|
        OrgIdentifier.new(a[:type], a[:id])
      end
      c
    end
  end

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
  end

  # Organization.
  class Organization < Contributor
    # @return [Array<RelatonBib::LocalizedString>]
    attr_reader :name

    # @return [RelatonBib::LocalizedString]
    attr_reader :abbreviation

    # @return [RelatonBib::LocalizedString]
    attr_reader :subdivision

    # @return [Array<RelatonBib::OrgIdentifier>]
    attr_reader :identifiers

    def hash2locstr(name)
      name.is_a?(Hash) ?
        LocalizedString.new(name[:content], name[:language], name[:script]) : 
        LocalizedString.new(name)
    end

    # @param name [String, Hash, Array<String, Hash>]
    # @param abbreviation [RelatoBib::LocalizedStrig, String]
    # @param subdivision [RelatoBib::LocalizedStrig, String]
    # @param url [String]
    # @param identifiers [Array<RelatonBib::OrgIdentifier>]
    # @param contacts [Array<RelatonBib::Address, RelatonBib::Phone>]
    def initialize(**args)
      raise ArgumentError, "missing keyword: name" unless args[:name]

      super(url: args[:url], contacts: args.fetch(:contacts, []))

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

      @identifiers  = args.fetch(:identifiers, [])
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
        identifiers.each { |identifier| identifier.to_xml builder }
        super
      end
    end
  end
end
