require "relaton_bib/formatted_string"

module RelatonBib
  class << self
    def formattedref_hash_to_bib(ret)
      ret[:formattedref] and ret[:formattedref] =
        formattedref(ret[:formattedref])
    end
  end

  class FormattedRef < FormattedString
    # @param [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.formattedref { super }
    end
  end
end
