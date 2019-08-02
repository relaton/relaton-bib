# frozen_string_literal: true

require "relaton_bib/person"

# RelatonBib module
module RelatonBib

  # Contributor's role.
  class ContributorRole
    TYPES = %w[author performer publisher editor adapter translator
               distributor
    ].freeze

    # @return [Array<RelatonBib::FormattedString>]
    attr_reader :description

    # @return [ContributorRoleType]
    attr_reader :type

    # @param type [String] allowed types "author", "editor",
    #   "cartographer", "publisher"
    # @param description [Array<String>]
    def initialize(**args)
      if args[:type] && !TYPES.include?(args[:type])
        raise ArgumentError, %{Type "#{type}" is invalid.}
      end

      @type = args[:type]
      @description = args.fetch(:description, []).map { |d| FormattedString.new content: d, format: nil }
    end

    def to_xml(builder)
      builder.role(type: type) do
        description.each do |d|
          builder.description { |desc| d.to_xml(desc) }
        end
      end
    end
  end

  # Contribution info.
  class ContributionInfo
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

    def to_xml(builder)
      entity.to_xml builder
    end
  end
end
