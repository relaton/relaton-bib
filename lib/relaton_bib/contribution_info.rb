# frozen_string_literal: true

require "relaton_bib/person"

# RelatonBib module
module RelatonBib
  # Contributor's role.
  class ContributorRole
    include RelatonBib

    TYPES = %w[author performer publisher editor adapter translator
               distributor].freeze

    # @return [Array<RelatonBib::FormattedString>]
    attr_reader :description

    # @return [Strig]
    attr_reader :type

    # @param type [String] allowed types "author", "editor",
    #   "cartographer", "publisher"
    # @param description [Array<String>]
    def initialize(**args)
      if args[:type] && !TYPES.include?(args[:type])
        warn %{[relaton-bib] Contributor's type "#{args[:type]}" is invalid.}
      end

      @type = args[:type]
      @description = args.fetch(:description, []).map { |d| FormattedString.new content: d, format: nil }
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.role(type: type) do
        description.each do |d|
          builder.description { |desc| d.to_xml(desc) }
        end
      end
    end

    # @return [Hash, String]
    def to_hash
      if description&.any?
        hash = { "description" => single_element_array(description) }
        hash["type"] = type if type
        hash
      elsif type
        type
      end
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
    # @param role [Array<String>]
    def initialize(entity:, role: [{ type: "publisher" }])
      @entity = entity
      @role   = role.map { |r| ContributorRole.new(**r) }
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      entity.to_xml builder
    end

    # @return [Hash]
    def to_hash
      hash = entity.to_hash
      hash["role"] = single_element_array(role) if role&.any?
      hash
    end
  end
end
