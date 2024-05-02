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

      # @return [String, nil]
      attr_reader :klass, :uri

      # @return [Array<RelatonBib::Element::Note>]
      attr_reader :note

      # @return [RelatonBib::Element::Tname, nil]
      attr_reader :tname

      #
      # Initialize paragraph with footnote
      #
      # @param content [Array<RelatonBib::Element::ParagraphWithFootnote>]
      # @param id [String] ID
      # @param type [String] admonition type
      # @param note [Array<RelatonBib::Element::Note>]
      # @param class [String, nil]
      # @param uri [String, nil]
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
        @klass = args[:class]
        @uri = args[:uri]
        @tname = args[:tname]
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder) # rubocop:disable Metrics/AbcSize
        builder.p(type: type) do |b|
          b.parent[:class] = klass if klass
          b.parent[:id] = id
          b.parent[:uri] = uri if uri
          tname&.to_xml b
          super b
          note.each { |n| n.to_xml b }
        end
      end
    end
  end
end
