module RelatonBib
  # Copyright association.
  class CopyrightAssociation
    # @return [Date]
    attr_reader :from

    # @return [Date, NilClass]
    attr_reader :to

    # @return [RelatonBib::ContributionInfo]
    attr_reader :owner

    # @param owner [Hash, RelatonBib::ContributionInfo] contributor
    # @option owner [String] :name
    # @option owner [String] :abbreviation
    # @option owner [String] :url
    # @param from [String] date
    # @param to [String, NilClass] date
    def initialize(owner:, from:, to: nil)
      @owner = if owner.is_a?(Hash)
                 ContributionInfo.new entity: Organization.new(owner)
               else owner
               end

      @from  = Date.strptime(from.to_s, "%Y") if from.to_s =~ /\d{4}/
      @to    = Date.strptime(to.to_s, "%Y") unless to.to_s.empty?
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.copyright do
        builder.from from ? from.year : "copyright year unknown"
        builder.to to.year if to
        builder.owner { owner.to_xml builder }
      end
    end

    # @return [Hash]
    def to_hash
      hash = { "owner" => owner.to_hash["organization"], "from" => from.year.to_s }
      hash["to"] = to.year.to_s if to
      hash
    end
  end
end
