require "nokogiri"

module Relaton
  module Bib
    # Strips inline markup not in the basicdoc PureTextElement set
    # (plus <p>, <eref>, <xref>, <fn>) from raw marked-up content strings.
    # Disallowed elements are unwrapped: tags removed, inner text kept.
    #
    # <fn> is admitted beyond strict PureTextElement because bibliographic
    # titles in real Metanorma input routinely carry footnotes (e.g. ISO
    # standards titles with a disclaimer footnote), and downstream
    # consumers — notably relaton-render's own inline-tag allow-list —
    # already accept <fn> as a legitimate child of <title>. Stripping it
    # here would break the round-trip.
    #
    # OPAQUE elements (currently <stem>) are also allowed, but the
    # sanitiser does not descend into them: their contents are out-of-band
    # inline notation (MathML, AsciiMath, LaTeX) rather than basicdoc
    # markup, and must be preserved verbatim. Without the opaque-skip,
    # the recursive walk would unwrap MathML / AsciiMath elements down to
    # bare text nodes — see #116 for the round-trip-loss symptom.
    module Sanitizer
      ALLOWED = %w[
        em strong sub sup tt underline strike smallcap br stem
        p eref xref fn
      ].freeze

      # Elements whose children are non-basicdoc inline notation
      # (MathML, AsciiMath, LaTeX, …) and must be preserved verbatim
      # rather than sanitised against ALLOWED.
      OPAQUE = %w[stem].freeze

      RENAME = {
        "italic" => "em",
      }.freeze

      TAG_RX = %r{<[a-zA-Z/!?]}

      def self.sanitize(content)
        return content unless sanitizable?(content)

        fragment = Nokogiri::XML::DocumentFragment.parse(content)
        return content if fragment.errors.any?

        sanitize_children(fragment)
        fragment.children.map { |c| c.to_xml(encoding: "UTF-8") }.join
      end

      def self.sanitizable?(content)
        content.is_a?(::String) && !content.empty? && content.match?(TAG_RX)
      end
      private_class_method :sanitizable?

      def self.sanitize_children(node)
        node.children.to_a.each do |child|
          next unless child.element?

          child.name = RENAME[child.name] if RENAME.key?(child.name)
          next if OPAQUE.include?(child.name)

          sanitize_children(child)
          child.replace(child.children) unless ALLOWED.include?(child.name)
        end
      end
      private_class_method :sanitize_children
    end
  end
end
