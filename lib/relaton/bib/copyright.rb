module Relaton
  module Bib
    # Copyright association.
    class Copyright
      # @return [Date]
      attr_accessor :from

      # @return [Date, nil]
      attr_accessor :to

      # @return [String, nil]
      attr_accessor :scope

      # @return [Array<Relaton::Bib::ContributionInfo>]
      attr_accessor :owner

      # @param owner [Array<Relaton::Bib::Person, Relaton::Bib::Organization>]
      # @param from [String] date
      # @param to [String, nil] date
      # @param scope [String, nil]
      def initialize(**args)
        # unless owner.any?
        #   raise ArgumentError, "at least one owner should exist."
        # end

        @owner = args[:owner]
        @from  = args[:rom]
        @to    = args[:o]
        @scope = args[:cope]
      end

      # @param opts [Hash]
      # @option opts [Nokogiri::XML::Builder] :builder XML builder
      # @option opts [String, Symbol] :lang language
      # def to_xml(**opts)
      #   opts[:builder].copyright do |builder|
      #     builder.from from ? from.year : "unknown"
      #     builder.to to.year if to
      #     owner.each { |o| builder.owner { o.to_xml(**opts) } }
      #     builder.scope scope if scope
      #   end
      # end

      # @return [Hash]
      # def to_hash # rubocop:disable Metrics/AbcSize
      #   owners = single_element_array(owner.map { |o| o.to_hash["organization"] })
      #   hash = {
      #     "owner" => owners,
      #     "from" => from.year.to_s,
      #   }
      #   hash["to"] = to.year.to_s if to
      #   hash["scope"] = scope if scope
      #   hash
      # end

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
end
