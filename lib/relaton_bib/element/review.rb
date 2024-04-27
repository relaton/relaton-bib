module RelatonBib
  module Element
    class Review
      include Base

      # @return [String]
      attr_reader :id, :reviewer

      # @!attribute [r] content
      #   @return [Array<RelatonBib::Element::Paragraph>]

      # @return [String, nil]
      attr_reader :type, :date, :from, :to

      #
      # Initializes a new instance of Review element.
      #
      # @param [String] id
      # @param [String] reviewer
      # @param [Array<RelatonBib::Element::Paragraph>] content
      # @param [String, nil] type
      # @param [String, nil] date datetime
      # @param [String, nil] from IDREF
      # @param [String, nil] to IDREF
      #
      def initialize(id:, reviewer:, content:, **args)
        @id = id
        @reviewer = reviewer
        @content = content
        @type = args[:type]
        @date = args[:date]
        @from = args[:from]
        @to = args[:to]
      end

      def to_xml(builder) # rubocop:disable Metrics/AbcSize
        builder.review(id: id, reviewer: reviewer) do |b|
          b.parent[:type] = type if type
          b.parent[:date] = date if date
          b.parent[:from] = from if from
          b.parent[:to] = to if to
          content.each { |c| c.to_xml b }
        end
      end
    end
  end
end
