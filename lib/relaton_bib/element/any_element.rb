module RelatonBib
  module Element
    class AnyElement
      include ToString

      # @return [String] node name
      attr_reader :name

      # @return [Relatonbib::Element::Text, RelatonBib::Element::AnyElement]
      attr_reader :content

      # @return [Hash] node attributes
      attr_reader :attrs

      #
      # Initialize object
      #
      # @param [String] name node name
      # @param [Array<Relatonbib::Element::Text, RelatonBib::Element::AnyElement>] content
      # @param [Hash] attrs node attributes
      #
      def initialize(name, content, attrs = {})
        @name = name
        @content = content
        @attrs = attrs
      end

      def to_xml(builder)
        builder.send(name, **attrs) do |b|
          content.each { |c| c.to_xml b }
        end
      end
    end
  end
end
