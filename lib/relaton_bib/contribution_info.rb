# frozen_string_literal: true

require "relaton_bib/person"

# RelatonBib module
module RelatonBib
  # Contributor's role.
  class ContributorRole
    include RelatonBib

    TYPES = %w[author performer publisher editor adapter translator
               distributor realizer owner authorizer enabler subject].freeze

    # @return [Array<RelatonBib::FormattedString>]
    attr_reader :description

    # @return [Strig]
    attr_reader :type

    # @param type [String] allowed types "author", "editor",
    #   "cartographer", "publisher"
    # @param description [Array<String>]
    def initialize(**args)
      if args[:type] && !TYPES.include?(args[:type])
        Util.warn %{Contributor's type `#{args[:type]}` is invalid.}
      end

      @type = args[:type]
      @description = (args[:description] || []).map do |d|
        FormattedString.new content: d, format: nil
      end
    end

    # @param opts [Hash]
    # @option opts [Nokogiri::XML::Builder] :builder XML builder
    # @option opts [String] :lang language
    def to_xml(**opts) # rubocop:disable Metrics/AbcSize
      opts[:builder].role(type: type) do |builder|
        desc = description.select { |d| d.language&.include? opts[:lang] }
        desc = description unless desc.any?
        desc.each do |d|
          builder.description { |b| d.to_xml(b) }
        end
      end
    end

    # @return [Hash, String]
    def to_hash
      hash = {}
      hash["description"] = description.map(&:to_hash) if description&.any?
      hash["type"] = type if type
      hash
    end

    # @param prefix [String]
    # @param count [Integer] number of contributors
    # 2return [String]
    def to_asciibib(prefix = "", count = 1)
      pref = prefix.empty? ? prefix : "#{prefix}."
      out = count > 1 ? "#{prefix}.role::\n" : ""
      description.each do |d|
        out += d.to_asciibib "#{pref}role.description", description.size
      end
      out += "#{pref}role.type:: #{type}\n" if type
      out
    end
  end

  # Contribution info.
  class ContributionInfo
    include RelatonBib

    # @return [Array<RelatonBib::ContributorRole>]
    attr_reader :role

    # @return
    #   [RelatonBib::Person, RelatonBib::Organization]
    attr_reader :entity

    # @param entity [RelatonBib::Person, RelatonBib::Organization]
    # @param role [Array<Hash>]
    # @option role [String] :type
    # @option role [Array<String>] :description
    def initialize(entity:, role: [])
      if role.empty?
        role << { type: entity.is_a?(Person) ? "author" : "publisher" }
      end
      @entity = entity
      @role   = role.map { |r| ContributorRole.new(**r) }
    end

    # @param opts [Hash]
    # @option opts [Nokogiri::XML::Builder] :builder XML builder
    # @option opts [String, Symbol] :lang language
    def to_xml(**opts)
      entity.to_xml(**opts)
    end

    # @return [Hash]
    def to_hash
      hash = entity.to_hash
      hash["role"] = single_element_array(role) if role&.any?
      hash
    end

    # @param prefix [String]
    # @param count [Integer] number of contributors
    # @return [String]
    def to_asciibib(prefix = "", count = 1)
      pref = prefix.split(".").first
      out = count > 1 ? "#{pref}::\n" : ""
      out += entity.to_asciibib prefix
      role.each { |r| out += r.to_asciibib pref, role.size }
      out
    end
  end
end
