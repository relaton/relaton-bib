module RelatonBib
  module Element
    #
    # TT can contain PureText eref, xref, hyperlink, index, and index-xref elements.
    #
    class Tt
      include RelatonBib::Element::Base

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.tt { |b| super b }
      end
    end
  end
end
