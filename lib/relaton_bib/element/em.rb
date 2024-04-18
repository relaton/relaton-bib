module RelatonBib
  module Element
    #
    # Em element can contain PureText, stem, eref, xref, hyperlink, index, and index-xref elements.
    #
    class Em
      include Base
      include ToString

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.em { |b| super b }
      end
    end
  end
end
