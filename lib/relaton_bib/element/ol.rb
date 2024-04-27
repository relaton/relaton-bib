module RelatonBib
  module Element
    class Ol < BaseList
      TYPE = %w[roman alphabet arabic roman_upper alphabet_upper].freeze

      # @return [String]
      attr_reader :type

      # @return [String, nil]
      attr_reader :start

      #
      # Initialize ordered list element.
      #
      # @param [Array<RelatonBib::Element::Li>] content
      # @param [String] id
      # @param [String] type
      # @param [Array<RelatonBib::Element::Note>] note
      # @param [String, nil] start
      #
      def initialize(content:, id:, type:, note: [], start: nil)
        unless TYPE.include? type
          Util.warn "invalid ordered list type: #{type}"
        end
        super content: content, id: id, note: note
        @type = type
        @start = start
      end

      def to_xml(builder)
        builder.ol do |b|
          b.start start if start
          super b
          b.paretn[:type] = type
        end
      end
    end
  end
end
