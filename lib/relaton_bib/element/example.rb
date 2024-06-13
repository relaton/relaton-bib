module RelatonBib
  module Element
    class Example
      include Base

      # @return [String]
      attr_reader :id

      # @!attribute [r] content
      #   @return [Array<RelatonBib::Element::Base>]

      # @return [Array<RelatonBib::Element::Note>]
      attr_reader :note

      # @return [Boolean, nil]
      attr_reader :unnumbered, :subsequence

      # @return [RelatonBib::Element::Tname, nil]
      attr_reader :tname

      #
      # Initialize Sourcecode element.
      #
      # @param id [String]
      # @param content [Array<RelatonBib::Element::Base>]
      # @param note [Array<RelatonBib::Element::Note>]
      # @param unnumbered [Boolean, nil]
      # @param subsequence [Boolean, nil]
      # @param tname [RelatonBib::Element::Tname, nil]
      #
      def initialize(id:, content:, note: [], **args)
        @id = id
        @content = content
        @note = note
        @unnumbered = args[:unnumbered]
        @subsequence = args[:subsequence]
        @tname = args[:tname]
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.example(id: id) do |b|
          b.parent["unnumbered"] = "true" if unnumbered
          b.parent["subsequence"] = "true" if subsequence
          tname&.to_xml b
          super b
          note.each { |n| n.to_xml b }
        end
      end
    end
  end
end
