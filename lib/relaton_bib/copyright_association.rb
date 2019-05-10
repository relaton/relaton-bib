module RelatonBib
  # Copyright association.
  class CopyrightAssociation
    # @return [Time]
    attr_reader :from

    # @return [Time]
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

      @from  = Time.strptime(from, "%Y") unless from.empty?
      @to    = Time.strptime(to, "%Y") unless to.to_s.empty?
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.copyright do
        builder.from from.year
        builder.to to.year if to
        builder.owner { owner.to_xml builder }
      end
    end
  end
end
