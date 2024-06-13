module RelatonBib
  module Element
    class Figure
      # @return [String]
      attr_reader :id

      # @return [RelatonBib::Element::Image, RelatonBib::Element::Video,
      #   RelatonBib::Element::Audio, RelatonBib::Element::Pre,
      #   Array<RelatonBib::Element::ParagraphWithFootnote>,
      #   Array<RelatonBib::Element::Figure>]
      attr_reader :content

      # @return [Array<RelatonBib::Element::Fn>]
      attr_reader :fn

      # @return [Array<RelatonBib::Element::Note>]
      attr_reader :note

      # @return [RelatonBib::Element::Source, nil]
      attr_reader :source

      # @return [RelatonBib::Element::Tname, nil]
      attr_reader :tname

      # @return [RelatonBib::Element::Dl]
      attr_reader :dl

      # @return [Boolean, nil]
      attr_reader :unnumbered, :subsequence, :klass

      #
      # Initialize figure element.
      #
      # @param [String] id
      # @param [RelatonBib::Element::Image, RelatonBib::Element::Video,
      #         RelatonBib::Element::Audio, RelatonBib::Element::Pre,
      #         Array<RelatonBib::Element::ParagraphWithFootnote>,
      #         Array<RelatonBib::Element::Figure>] content
      # @param [Array<RelatonBib::Element::Fn>] fn
      # @param [Array<RelatonBib::Element::Note>] note
      # @param [Boolena, nil] unnumbered
      # @param [String, nil] subsequence
      # @param [String, nil] class
      # @param [RelatonBib::Element::Source, nil] source
      # @param [RelatonBib::Element::Tname, nil] tname
      # @param [RelatonBib::Element::Dl, nil] dl
      #
      def initialize(id:, content:, note: [], **args)
        @id = id
        @content = content
        @fn = args[:fn] || []
        @note = note
        @unnumbered = args[:unnumbered]
        @subsequence = args[:subsequence]
        @klass = args[:class]
        @source = args[:source]
        @tname = args[:tname]
        @dl = args[:dl]
      end

      def to_xml(builder) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength, Metrics/AbcSize
        node = builder.figure(id: id) do |b|
          source&.to_xml b
          tname&.to_xml b
          RelatonBib.array(content).each { |c| c.to_xml b }
          fn.each { |f| f.to_xml b }
          dl&.to_xml b
          note.each { |n| n.to_xml b }
        end
        node[:unnumbered] = unnumbered unless unnumbered.nil?
        node[:subsequence] = subsequence if subsequence
        node[:class] = klass if klass
        node
      end
    end
  end
end
