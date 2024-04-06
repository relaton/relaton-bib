module RelatonBib
  module Element
    #
    # ErefType can contain both, CitationType and PureText elements.
    #
    class ErefType
      include RelatonBib::Element::Base
      include RelatonBib::Element::ReferenceFormat

      # @return [String]
      attr_reader :type, :citeas

      # @return [RelatonBib::Element::CitationType]
      attr_reader :citaion_type

      # @return [String, nil]
      attr_reader :normative, :alt

      # @param content [Array<RelatonBib::Element::Base, RelatonBib::Element::Text, RelatonBib::Edition::PureText>]
      # @param citeas [String]
      # @param type [String]
      # @param citaion_type [RelatonBib::Edition::CitationType]
      # @param args [Hash]
      # @option args [String, nil] :normative
      # @option args [String, nil] :alt
      def initialize(content:, citeas:, type:, citaion_type:, **args)
        Util.warn "invalid eref type: `#{type}`" unless TYPES.include? type
        super content
        @citeas = citeas
        @type = type
        @citaion_type = citaion_type
        @normative = args[:normative]
        @alt = args[:alt]
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder) # rubocop:disable Metrics/AbcSize
        builder.parent do |b|
          citaion_type.to_xml b
          super b
        end
        builder.parent["citeas"] = citeas
        builder.parent["type"] = type
        builder.parent["normative"] = normative if normative
        builder.parent["alt"] = alt if alt
      end
    end
  end
end
