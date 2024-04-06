module RelatonBib
  module Element
    #
    # Sub can contain PureText elements.
    #
    class Sub
      include RelatonBib::Element::Base

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.sub { |b| super b }
      end
    end
  end
end
