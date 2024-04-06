module RelatonBib
  module Element
    class CitationType
      # @return [String]
      attr_reader :bibitemid

      # @return [Array<RelatonBib::Locality, RelatonBib::LocalityStack>]
      attr_reader :locality

      # @return [String, nil]
      attr_reader :date

      #
      # Initialize CitationType
      #
      # @param [String] bibitemid IDREF of the bibliographic item
      # @param [Hash] **args
      # @option args [Array<RelatonBib::Locality, RelatonBib::LocalityStack, nil>] :locality
      # @option args [String, nil] :date ISO8601Date
      #
      def initialize(bibitemid, **args)
        @bibitemid = bibitemid
        @locality = args[:locality] || []
        @date = args[:date]
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.parent[:bibitemid] = bibitemid
        builder.parent[:date] = date if date
        builder.parent { |b| locality.each { |l| l.to_xml b } }
      end
    end
  end
end
