module RelatonBib
  module Element
    class ParagraphWithFootnote
      include Alignments
      include Base
      include ToString

      # @!attribute [r] content
      #   @return [Array<RelatonBib::Element::Text, RelatonBib::Element::Base, RelatonBib::Element::Fn>]

      # @return [String, nil]
      attr_reader :id

      # @return [String, nil] alignment left, right, center, or justify
      attr_reader :align

      # @return [Array<RelatonBib::Element::Note>]
      attr_reader :note

      #
      # Initialize paragraph with footnote
      #
      # @param content [Array<RelatonBib::Element::Text, RelatonBib::Element::Base, RelatonBib::Element::Fn>]
      # @param id [String, nil] ID
      # @param align [String, nil] alignment left, right, center, or justify
      # @param note [Array<RelatonBib::Element::Note>]
      #
      def initialize(content:, id: nil, align: nil, note: [])
        check_alignment align
        super content: content
        @id = id
        @align = align
        @note = note
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        node = builder.p do |b|
          super b
          note.each { |n| n.to_xml b }
        end
        node[:id] = id if id
        node[:align] = align if align
      end
    end
  end
end
