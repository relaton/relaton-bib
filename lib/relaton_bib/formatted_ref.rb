require "relaton_bib/formatted_string"

module RelatonBib
  class FormattedRef < FormattedString
    # @param [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.formattedref { super }
    end
  end
end
