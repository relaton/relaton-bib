module RelatonBib
  module Element
    class Video
      include MediaSize
      include Base
      include Media

      # @!attribute [r] content
      #   @return [Array<RelatonBib::Element::Altsource>]

      #
      # Initialize video element.
      #
      # @param [String] id
      # @param [Array<RelatonBib::Element::Altsource>] content
      # @param [String] src any URI
      # @param [String] mimetype
      # @param [String, nil] filename
      # @param [String, nil] width integer in pixels or "auto"
      # @param [String, nil] height integer in pixels or "auto"
      # @param [String, nil] alt
      # @param [String, nil] title
      # @param [String, nil] longdesc any URI
      #
      def initialize(id:, content:, src:, mimetype:, **args)
        super
        @content = content
      end

      def to_xml(builder)
        builder.video { |b| super b }
      end

      def to_h
        hash = super
        hash["content"] = content.map(&:to_h)
        hash
      end

      def to_asciibib(prefix = "")
        pref = prefix.empty? ? "video." : "#{prefix}.video."
        out = super pref
        content.each { |c| out += c.to_asciibib(pref) }
        out
      end
    end
  end
end
