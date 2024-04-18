module RelatonBib
  module Element
    #
    # Base module for many elements.
    #
    module Base
      # @return [Array<RelatonBib::Element::Text, RelatonBib::Element::Base>]
      attr_reader :content

      # @param content [Array<RelatonBib::Element::Text, RelatonBib::Element::Em>]
      def initialize(content:, **args)
        @content = content
        super(**args) if defined? super
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        super if defined? super
        content.each { |c| c.to_xml builder }
      end

      def to_h
        { "content" => to_s }
      end

      def to_s
        content.map(&:to_s).join
      end

      def to_asciibib(prefix = "")
        pref = prefix.empty? ? "content" : "#{prefix}.content"
        out = "#{pref}:: #{self}\n"
        out += super(prefix) if defined? super
        out
      end
    end
  end
end
