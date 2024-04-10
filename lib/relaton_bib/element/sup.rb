module RelatonBib
  module Element
    #
    # Sub can contain PureText elements.
    #
    class Sup
      include RelatonBib::Element::Base

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.sup { |b| super b }
      end
    end
  end
end