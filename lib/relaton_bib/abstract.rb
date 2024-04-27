module RelatonBib
  class Abstract
    include LocalizedStringAttrs
    include RelatonBib::Element::Base

    # @!attribute [r] content BasicBlock, TextElement
    #   @return [Array<RelatonBib::Element::Base>]

    #
    # Initialize abstract
    # language and script can be multiple: comma delimit them if so
    #
    # @param [Array<RelatonBib::Element::Base>, Strign] content abstract content
    # @param [Array<String>, String] :language language code Iso639
    # @param [Array<Atring>, String] :script script code Iso15924
    # @param [String, nil] :locale
    #
    def initialize(content:, **args)
      super
      if content.is_a?(String)
        @content = Element.parse_basic_block_elements(content)
        @content = Element.parse_text_elements(content) if @content.empty?
      else
        @content = content
      end
    end

    def to_xml(builder)
      builder.abstract { |b| super b }
    end

    def to_asciibib(prefix = "", count = 1)
      pref = prefix.empty? ? "abstract" : "#{prefix}.abstract"
      out = count > 1 ? "#{pref}::\n" : ""
      out += super(pref)
      out
    end
  end
end
