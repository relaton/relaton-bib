module RelatonBib
  class Abstract
    include Element::Base
    include LocalizedStringAttrs

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
      @content = content.is_a?(String) ? Element.parse_text_elements(content) : content
      super(**args)
    end

    def to_xml(builder)
      builder.abstract do |b|
        Element::Base.instance_method(:to_xml).bind_call(self, b)
        super b
      end
    end

    def to_hash
      hash = { "content" => to_s }
      hash.merge super
    end

    def to_asciibib(prefix = "", count = 1)
      pref = prefix.empty? ? "abstract" : "#{prefix}.abstract"
      out = count > 1 ? "#{pref}::\n" : ""
      out += "#{pref}.content:: #{self}\n"
      out += super(pref)
      out
    end
  end
end
