module Relaton
  module Bib
    class FormattedRef < FormattedString
      # @param [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.formattedref { super }
      end

      # @param prefix [String]
      # @return [String]
      def to_asciibib(prefix = "")
        pref = prefix.empty? ? "formattedref" : "#{prefix}.formattedref"
        super pref
      end
    end
  end
end
