module RelatonBib
  # Copyright association.
  class CopyrightAssociation
    include RelatonBib

    # @return [Date]
    attr_reader :from

    # @return [Date, nil]
    attr_reader :to

    # @return [String, nil]
    attr_reader :scope

    # @return [Array<RelatonBib::ContributionInfo>]
    attr_reader :owner

    # rubocop:disable Metrics/AbcSize

    # @param owner [Array<Hash, RelatonBib::ContributionInfo>] contributor
    # @option owner [String] :name
    # @option owner [String] :abbreviation
    # @option owner [String] :url
    # @param from [String] date
    # @param to [String, nil] date
    # @param scope [String, nil]
    def initialize(owner:, from:, to: nil, scope: nil)
      unless owner.any?
        raise ArgumentError, "at least one owner should exist."
      end

      @owner = owner.map do |o|
        o.is_a?(Hash) ? ContributionInfo.new(entity: Organization.new(**o)) : o
      end

      @from  = Date.strptime(from.to_s, "%Y") if from.to_s.match?(/\d{4}/)
      @to    = Date.strptime(to.to_s, "%Y") unless to.to_s.empty?
      @scope = scope
    end

    # @param opts [Hash]
    # @option opts [Nokogiri::XML::Builder] :builder XML builder
    # @option opts [String, Symbol] :lang language
    def to_xml(**opts)
      opts[:builder].copyright do |builder|
        builder.from from ? from.year : "unknown"
        builder.to to.year if to
        owner.each { |o| builder.owner { o.to_xml(**opts) } }
        builder.scope scope if scope
      end
    end
    # rubocop:enable Metrics/AbcSize

    # @return [Hash]
    def to_hash # rubocop:disable Metrics/AbcSize
      owners = single_element_array(owner.map { |o| o.to_hash["organization"] })
      hash = {
        "owner" => owners,
        "from" => from.year.to_s,
      }
      hash["to"] = to.year.to_s if to
      hash["scope"] = scope if scope
      hash
    end

    # @param prefix [String]
    # @param count [Iteger] number of copyright elements
    # @return [String]
    def to_asciibib(prefix = "", count = 1) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      pref = prefix.empty? ? "copyright" : "#{prefix}.copyright"
      out = count > 1 ? "#{pref}::\n" : ""
      owner.each { |ow| out += ow.to_asciibib "#{pref}.owner", owner.size }
      out += "#{pref}.from:: #{from.year}\n" if from
      out += "#{pref}.to:: #{to.year}\n" if to
      out += "#{pref}.scope:: #{scope}\n" if scope
      out
    end
  end
end
