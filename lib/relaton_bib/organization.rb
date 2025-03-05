# frozen_string_literal: true

require "relaton_bib/contributor"

module RelatonBib
  # Organization identifier.
  class OrgIdentifier
    # ORCID = "orcid"
    # URI   = "uri"

    # @return [String]
    attr_reader :type

    # @return [String]
    attr_reader :value

    # @param type [String]
    # @param value [String]
    def initialize(type, value)
      # unless [ORCID, URI].include? type
      #   raise ArgumentError, 'Invalid type. It should be "orsid" or "uri".'
      # end

      @type  = type
      @value = value
    end

    def ==(other)
      type == other.type && value == other.value
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.identifier(value, type: type)
    end

    # @return [Hash]
    def to_hash
      { "type" => type, "id" => value }
    end

    # @param prefix [String]
    # @param count [Integer]
    # @return [String]
    def to_asciibib(prefix = "", count = 1)
      pref = prefix.empty? ? prefix : "#{prefix}."
      out = count > 1 ? "#{pref}identifier::\n" : ""
      out += "#{pref}identifier.type:: #{type}\n"
      out += "#{pref}identifier.value:: #{value}\n"
      out
    end
  end

  # Organization.
  class Organization < Contributor
    # @return [Array<RelatonBib::LocalizedString>]
    attr_reader :name

    # @return [RelatonBib::LocalizedString, nil]
    attr_reader :abbreviation

    # @return [Array<RelatonBib::LocalizedString>]
    attr_reader :subdivision

    # @return [Array<RelatonBib::OrgIdentifier>]
    attr_reader :identifier

    # @return [RelatonBib::Image, nil]
    attr_reader :logo

    # @param name [String, Hash, Array<String, Hash>]
    # @param abbreviation [RelatoBib::LocalizedString, String]
    # @param subdivision [Array<RelatoBib::LocalizedString>]
    # @param url [String]
    # @param identifier [Array<RelatonBib::OrgIdentifier>]
    # @param contact [Array<RelatonBib::Address, RelatonBib::Contact>]
    # @param logo [RelatonBib::Image, nil]
    def initialize(**args) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      raise ArgumentError, "missing keyword: name" unless args[:name]

      super(url: args[:url], contact: args[:contact] || [])

      @name = if args[:name].is_a?(Array)
                args[:name].map { |n| localized_string(n) }
              else
                [localized_string(args[:name])]
              end

      @abbreviation = localized_string args[:abbreviation]
      @subdivision  = (args[:subdivision] || []).map do |sd|
        localized_string sd
      end
      @identifier = args[:identifier] || []
      @logo = args[:logo]
    end

    def ==(other)
      name == other.name && abbreviation == other.abbreviation &&
        subdivision == other.subdivision && identifier == other.identifier &&
        logo == other.logo && super
    end

    # @param opts [Hash]
    # @option opts [Nokogiri::XML::Builder] :builder XML builder
    # @option opts [String] :lang language
    def to_xml(**opts) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/MethodLength
      opts[:builder].organization do |builder|
        nm = name.select { |n| n.language&.include? opts[:lang] }
        nm = name unless nm.any?
        nm.each { |n| builder.name { |b| n.to_xml b } }
        sbdv = subdivision.select { |sd| sd.language&.include? opts[:lang] }
        sbdv = subdivision unless sbdv.any?
        sbdv.each { |sd| builder.subdivision { sd.to_xml builder } }
        builder.abbreviation { |a| abbreviation.to_xml a } if abbreviation
        builder.uri url if uri
        identifier.each { |identifier| identifier.to_xml builder }
        super builder
        builder.logo { |b| logo.to_xml b } if logo
      end
    end

    # @return [Hash]
    def to_hash # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity
      hash = { "name" => single_element_array(name) }
      hash["abbreviation"] = abbreviation.to_hash if abbreviation
      hash["identifier"] = single_element_array(identifier) if identifier&.any?
      if subdivision&.any?
        hash["subdivision"] = single_element_array(subdivision)
      end
      hash["logo"] = logo.to_hash if logo
      { "organization" => hash.merge(super) }
    end

    # @param prefix [String]
    # @param count [Integer]
    # @return [String]
    def to_asciibib(prefix = "", count = 1) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
      pref = prefix.sub(/\*$/, "organization")
      out = count > 1 ? "#{pref}::\n" : ""
      name.each { |n| out += n.to_asciibib "#{pref}.name", name.size }
      out += abbreviation.to_asciibib "#{pref}.abbreviation" if abbreviation
      subdivision.each do |sd|
        out += "#{pref}.subdivision::" if subdivision.size > 1
        out += sd.to_asciibib "#{pref}.subdivision"
      end
      identifier.each { |n| out += n.to_asciibib pref, identifier.size }
      out += super pref
      out += logo.to_asciibib "#{pref}.logo" if logo
      out
    end

    private

    # @param arg [String, Hash, RelatoBib::LocalizedString]
    # @return [RelatoBib::LocalizedString]
    def localized_string(arg)
      case arg
      when String then LocalizedString.new(arg)
      when Hash
        LocalizedString.new(arg[:content], arg[:language], arg[:script])
      when LocalizedString then arg
      end
    end
  end
end
