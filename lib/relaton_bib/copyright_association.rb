module RelatonBib
  # Copyright association.
  class CopyrightAssociation
    include RelatonBib

    # @return [Date]
    attr_reader :from

    # @return [Date, NilClass]
    attr_reader :to

    # @return [String, NilClass]
    attr_reader :scope

    # @return [Array<RelatonBib::ContributionInfo>]
    attr_reader :owner

    # rubocop:disable Metrics/AbcSize

    # @param owner [Array<Hash, RelatonBib::ContributionInfo>] contributor
    # @option owner [String] :name
    # @option owner [String] :abbreviation
    # @option owner [String] :url
    # @param from [String] date
    # @param to [String, NilClass] date
    # @param scope [String, NilClass]
    def initialize(owner:, from:, to: nil, scope: nil)
      unless owner.any?
        raise ArgumentError, "at least one owner should exist."
      end

      @owner = owner.map do |o|
        o.is_a?(Hash) ? ContributionInfo.new(entity: Organization.new(o)) : o
      end

      @from  = Date.strptime(from.to_s, "%Y") if from.to_s =~ /\d{4}/
      @to    = Date.strptime(to.to_s, "%Y") unless to.to_s.empty?
      @scope = scope
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.copyright do
        builder.from from ? from.year : "unknown"
        builder.to to.year if to
        owner.each { |o| builder.owner { o.to_xml builder } }
        builder.scope scope if scope
      end
    end
    # rubocop:enable Metrics/AbcSize

    # @return [Hash]
    def to_hash
      owners = single_element_array(owner.map { |o| o.to_hash["organization"] })
      hash = {
        "owner" => owners,
        "from" => from.year.to_s,
      }
      hash["to"] = to.year.to_s if to
      hash["scope"] = scope if scope
      hash
    end
  end
end
