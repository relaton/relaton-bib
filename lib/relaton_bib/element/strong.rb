module RelatonBib
  module Element
    #
    # Strong can contain PureText, stem, eref, xref, hyperlink, index, and index-xref elements.
    #
    class Strong
      include Base
      include ToString

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.strong { |b| super b }
      end
    end
  end
end
