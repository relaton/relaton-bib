module RelatonBib
  class Abstract
    include LocalizedStringAttrs
    include Element::Base

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
      @content = content.is_a?(String) ? Element.parse_text_elements(content) : content
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
