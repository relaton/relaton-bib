module Relaton
  module Bib
    class Locality < BibItemLocality
      # @param builder [Nokogiri::XML::Builder]
      # def to_xml(builder)
      #   builder.locality { |b| super(b) }
      # end

      #
      # Render locality as hash.
      #
      # @return [Hash] locality as hash.
      #
      # def to_hash
      #   { "locality" => super }
      # end

      #
      # Render locality as AsciiBib.
      #
      # @param [String] prefix prefix of locality
      # @param [Integer] count number of localities
      #
      # @return [String] AsciiBib.
      #
      def to_asciibib(prefix = "", count = 1)
        pref = prefix.empty? ? "locality" : "#{prefix}.locality"
        super(pref, count)
      end
    end

    class SourceLocality < BibItemLocality
      # @param builder [Nokogiri::XML::Builder]
      # def to_xml(builder)
      #   builder.sourceLocality { |b| super(b) }
      # end
    end
  end
end
