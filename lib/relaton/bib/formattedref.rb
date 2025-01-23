module Relaton
  module Bib
    class Formattedref
      # @return [String]
      attr_accessor :content

      def initialize(**args)
        @content = args[:content]
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
