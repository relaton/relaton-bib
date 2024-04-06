module RelatonBib
  module Element
    module IndexShared
      # @return [Array<RelatonBib::PureTextElement>]
      attr_reader :primary, :secondary, :tertiary

      #
      # Initializer
      #
      # @param [Array<RelatonBib::Element::PureText>] primary
      # @param [Array<RelatonBib::Element::PureText>] secondary
      # @param [Array<RelatonBib::Element::PureText>] tertiary
      #
      def initialize(primary, secondary: [], tertiary: [])
        @primary = primary
        @secondary = secondary
        @tertiary = tertiary
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.primary { |b| primary.each { |p| p.to_xml b } }
        builder.secondary { |b| secondary.each { |s| s.to_xml b } }
        builder.tertiary { |b| tertiary.each { |t| t.to_xml b } }
      end
    end

    class Index
      include IndexShared

      # @return [String, nil]
      attr_reader :to

      #
      # Initialize index element
      #
      # @param [Array<RelatonBib::Element::PureText>] primary
      # @param [Array<RelatonBib::Element::PureText>] secondary
      # @param [Array<RelatonBib::Element::PureText>] tertiary
      # @param [String, nil] to IDREF
      #
      def initialize(primary, secondary: [], tertiary: [], to: nil)
        super primary, secondary: secondary, tertiary: tertiary
        @to = to
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        node = builder.index { |b| super b }
        node[:to] = to if to
      end
    end

    class IndexXref
      include IndexShared

      # @return [Array<RelatonBib::Element::PureText>]
      attr_reader :target

      # @return [Boolean]
      attr_reader :also

      #
      # Initialize index xref element
      #
      # @param [Array<RelatonBib::Element::PureText>] primary
      # @param [Array<RelatonBib::Element::PureText>] secondary
      # @param [Array<RelatonBib::Element::PureText>] tertiary
      # @param [Array<RelatonBib::Element::PureText>] target
      # @param [Boolean] also
      #
      def initialize(primary, target:, also:, secondary: [], tertiary: [])
        super primary, secondary: secondary, tertiary: tertiary
        @target = target
        @also = also
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        node = builder.send("index-xref") do |b|
          super b
          b.target { |t| target.each { |el| el.to_xml t } }
        end
        node[:also] = also unless also.nil?
      end
    end
  end
end
