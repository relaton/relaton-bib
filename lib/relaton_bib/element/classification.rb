module RelatonBib
  module Element
    class Classification
      class Tag < Text
        def to_xml(builder)
          builder.tag { |b| super b }
        end
      end

      class Value < Text
        def to_xml(builder)
          builder.value { |b| super b }
        end
      end

      # @return [RelatonBib::Element::Classification::Tag]
      attr_reader :tag

      # @return [RelatonBib::Element::Classification::Value]
      attr_reader :value

      #
      # Initializes classification element.
      #
      # @param [RelatoBib::Element::Classification::Tag] tag
      # @param [RelatoBib::Element::Classification::Value] value
      #
      def initialize(tag:, value:)
        @tag = tag
        @value = value
      end

      def to_xml(builder)
        builder.classification do |b|
          tag.to_xml b
          value.to_xml b
        end
      end
    end
  end
end
