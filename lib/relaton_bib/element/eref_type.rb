module RelatonBib
  module Element
    #
    # ErefType can contain both, CitationType and PureText elements.
    #
    class ErefType
      include ReferenceFormat
      include Base

      # @return [String]
      attr_reader :type, :citeas

      # @return [RelatonBib::Element::CitationType]
      attr_reader :citation_type

      # @return [String, nil]
      attr_reader :normative, :alt

      # @param content [Array<RelatonBib::Element::Base, RelatonBib::Element::Text, RelatonBib::Element::PureText>]
      # @param citeas [String]
      # @param type [String] one of external, inline, footnote, or callout
      # @param citation_type [RelatonBib::Element::CitationType]
      # @param args [Hash]
      # @option args [String, nil] :normative
      # @option args [String, nil] :alt
      def initialize(content, citeas:, type:, citation_type:, **args)
        check_type type
        super content: content
        @citeas = citeas
        @type = type
        @citation_type = citation_type
        @normative = args[:normative]
        @alt = args[:alt]
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder) # rubocop:disable Metrics/AbcSize
        builder.parent["normative"] = normative if normative
        builder.parent["citeas"] = citeas
        builder.parent["type"] = type
        builder.parent["alt"] = alt if alt
        citation_type.to_xml(builder)
        super builder
      end
    end
  end
end
