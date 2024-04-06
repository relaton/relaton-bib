require "relaton_bib/formatted_string"

module RelatonBib
  class FormattedRef
    include RelatonBib::Element::Base

    #
    # Formatted reference content.
    #
    # @param [String, RelatonBib::Element::Base] content
    #
    def initialize(content)
      @content = content.is_a?(String) ? Element.parse_text_elements(content) : content
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
