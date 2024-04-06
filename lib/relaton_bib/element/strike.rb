module RelatonBib
  module Element
    #
    # Strike can contain PureTextEement, index, and index-xref elements.
    #
    class Strike
      include RelatonBib::Element::Base

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.strike { |b| super b }
      end
    end
  end
end
