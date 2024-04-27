module RelatonBib
  module Element
    class Sourcecode
      include Base

      # @return [String]
      attr_reader :id

      # @!attribute [r] content
      #   @return [Array<RelatonBib::Element::Text, RelatonBib::Element::Callout>]

      # @return [Array<RelatonBib::Element::Annotation>]
      attr_reader :annotation

      # @return [Array<RelatonBib::Element::Note>]
      attr_reader :note

      # @return [Boolean, nil]
      attr_reader :unnumbered

      # @return [String, nil]
      attr_reader :subsequence, :lang

      # @return [RelatonBib::Element::Tname, nil]
      attr_reader :tname

      #
      # Initialize Sourcecode element.
      #
      # @param [String] id
      # @param [Array<RelatonBib::Element::Text, RelatonBib::Element::Callout>] content
      # @param [Array<RelatonBib::Element::Annotation>] annotation
      # @param [Array<RelatonBib::Element::Note>] note
      # @param [Boolean, nil] unnumbered
      # @param [String, nil] subsequence
      # @param [String, nil] lang
      # @param [RelatonBib::Element::Tname, nil] tname
      #
      def initialize(id:, content:, annotation: [], note: [], **args)
        @id = id
        @unnumbered = args[:unnumbered]
        @subsequence = args[:subsequence]
        @lang = args[:lang]
        @tname = args[:tname]
        super content
        @annotation = annotation
        @note = note
      end

      def to_xml(builder) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
        node = builder.sourcecode id: id do |b|
          tname&.to_xml b
          super b
          annotation.each { |a| a.to_xml builder }
          note.each { |n| n.to_xml builder }
        end
        node[:unnumbered] = true if unnumbered
        node[:subsequence] = subsequence if subsequence
        node[:lang] = lang if lang
      end
    end
  end
end
