require "relaton_bib/formatted_string"

module RelatonBib
  class FormattedRef
    include Element::Base

    #
    # Formatted reference content.
    #
    # @param [String, Array<RelatonBib::Element::Base, RelatonBib::Element::Text>] content
    #
    def initialize(content)
      @content = content.is_a?(String) ? Element::TextElement.parse(content) : content
    end

    # @param [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.formattedref { |b| super b }
    end

    # @param prefix [String]
    # @return [String]
    def to_asciibib(prefix = "")
      pref = prefix.empty? ? "formattedref" : "#{prefix}.formattedref"
      "#{pref}:: #{self}\n"
    end
  end
end
