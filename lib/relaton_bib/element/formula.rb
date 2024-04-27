module RelatonBib
  module Element
    class Formula
      # @return [String]
      attr_reader :id

      # @return [RelatonBib::Element::Stem]
      attr_reader :stem

      # @return [Array<RelatonBib::Element::Note>]
      attr_reader :note

      # @return [Boolean, nil]
      attr_reader :unnumbered, :inequality

      # @return [String, nil]
      attr_reader :subsequence

      # @return [RelatonBib::Element::Dl, nil]
      attr_reader :dl

      #
      # Initialize formula element
      #
      # @param [String] id
      # @param [RelatonBib::Element::Stem] stem
      # @param [Array<RelatonBib::Element::Note>] note
      # @param [Boolean, nil] unnumbered
      # @param [String, nil] subsequence
      # @param [Boolean, nil] inequality
      # @param [RelatonBib::Element::Dl, nil] dl
      #
      def initialize(id:, stem:, note: [], **args)
        @id = id
        @stem = stem
        @note = note
        @unnubered = args[:unnumbered]
        @subsequence = args[:subsequence]
        @inequality = args[:inequality]
        @dl = args[:dl]
      end
    end

    def to_xml(builder) # rubocop:disable Metrics/AbcSize
      node = builder.formula id: id do |b|
        stem.to_xml b
        dl&.to_xml b
        note.each { |n| n.to_xml b }
      end
      node[:unnumbered] = "true" if unnumbered
      node[:subsequence] = subsequence if subsequence
      node[:inequality] = inequality unless inequality.nil?
    end
  end
end
