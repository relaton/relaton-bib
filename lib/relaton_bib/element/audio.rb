module RelatonBib
  module Element
    class Audio
      include Base
      include Media

      #
      # Initializes a new instance of Audio element.
      #
      # @param [String] id
      # @param [Array<RelatonBib::Element::Altsource>] content
      # @param [String] src any URI
      # @param [String] mimetype
      # @param [String, nil] filename
      # @param [String, nil] alt
      # @param [String, nil] title
      # @param [String, nil] longdesc
      #
      def initialize(id:, content:, src:, mimetype:, **args)
        super
        @content = content
      end

      def to_xml(builder)
        builder.audio { |b| super b }
      end

      def to_h
        hash = super
        hash["content"] = content.map(&:to_h)
        hash
      end

      def to_asciibib(prefix = "")
        pref = prefix.empty? ? "audio." : "#{prefix}.audio."
        out = super pref
        content.each { |c| out += c.to_asciibib(pref) }
        out
      end
    end
  end
end
