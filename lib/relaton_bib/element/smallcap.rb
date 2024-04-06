module RelatonBib
  module Element
    #
    # Smallcap can contain PureText elements.
    #
    class Smallcap
      include RelatonBib::Element::Base

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.smallcap { |b| super b }
      end
    end
  end
end
