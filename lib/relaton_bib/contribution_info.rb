# frozen_string_literal: true

require "relaton_bib/person"

# RelatonBib module
module RelatonBib
  class << self
    def is_person_hash(c)
      c.is_a?(Hash) and c[:entity].is_a?(Hash) and
        c[:entity][:name].is_a?(Hash) and
        (c.dig(:entity, :name, :completename) ||
         c.dig(:entity, :name, :surname))
    end

    def contributors_hash_to_bib(ret)
      return unless ret[:contributors]
      ret[:contributors] = array(ret[:contributors])
      ret[:contributors]&.each_with_index do |c, i|
        ret[:contributors][i][:roles] = array(ret[:contributors][i][:roles])
        ret[:contributors][i][:entity] = is_person_hash(c) ?
          person_hash_to_bib(c[:entity]) : org_hash_to_bib(c[:entity])
      end
    end
  end

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
    def initialize(*args)
      @type = args.fetch 0
      if type && !TYPES.include?(type)
        raise ArgumentError, %{Type "#{type}" is invalid.}
      end

      @description = args.fetch(1, []).map { |d| FormattedString.new content: d, format: nil }
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
    def initialize(entity:, role: ["publisher"])
      @entity = entity
      @role   = role.map { |r| ContributorRole.new(*r) }
    end

    def to_xml(builder)
      entity.to_xml builder
    end
  end
end
