module RelatonBib
  module Element
    class Admonition
      include ToString
      include Base

      TYPES = %w[warning note tip important caution].freeze

      # @return [Array<RelatonBib::Element::ParagraphWithFootnote>]
      attr_reader :content

      # @return [String]
      attr_reader :id, :type

      # @return [String, nil] alignment left, right, center, or justify
      attr_reader :align

      # @return [Array<RelatonBib::Element::Note>]
      attr_reader :note

      #
      # Initialize paragraph with footnote
      #
      # @param content [Array<RelatonBib::Element::ParagraphWithFootnote>]
      # @param id [String] ID
      # @param type [String] admonition type
      # @param note [Array<RelatonBib::Element::Note>]
      # @param klass [String, nil]
      # @param url [String, nil]
      # @param tname [RelatonBib::Element::Tname, nil]
      #
      def initialize(content:, id:, type:, note: [], **args)
        unless TYPES.include? type
          Util.warn "admonition type should be one of: #{TYPES.join ', '}"
        end
        super content: content
        @id = id
        @type = type
        @note = note
        @klass = args[:klass]
        @url = args[:url]
        @tname = args[:tname]
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder) # rubocop:disable Metrics/AbcSize
        node = builder.p(id: id, type: type) do |b|
          tname&.to_xml b
          super b
          note.each { |n| n.to_xml b }
        end
        node[:class] = klass if klass
        node[:url] = url if url
      end
    end
  end
end
