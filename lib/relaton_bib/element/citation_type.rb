module RelatonBib
  module Element
    class CitationType
      include ToString

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
      # @param [Array<RelatonBib::Locality, RelatonBib::LocalityStack>] locality
      # @param [String, nil] date ISO8601Date
      #
      def initialize(bibitemid, **args)
        @bibitemid = bibitemid
        @locality = args[:locality] || []
        @date = args[:date]
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.parent[:bibitemid] = bibitemid
        locality.each { |l| l.to_xml builder }
        builder.date date if date
      end
    end
  end
end
