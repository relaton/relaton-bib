module RelatonBib
  module Element
    class Image
      include MediaSize
      include Media

      #
      # Converts the image object to XML format.
      #
      # @param [Nokogiri::XML::Builder] builder The XML builder object.
      #
      # @return [void]
      #
      def to_xml(builder)
        builder.image { |b| super b }
      end

      #
      # Converts the Image object to a hash representation.
      #
      # @return [Hash] The hash representation of the Image object.
      #
      def to_h
        { "image" => super }
      end

      #
      # Converts the image object to AsciiBib format.
      #
      # @param prefix [String] The prefix to be added to the AsciiBib output.
      #
      # @return [String] The image object converted to AsciiBib format.
      #
      def to_asciibib(prefix = "") # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/MethodLength
        pref = prefix.empty? ? "image." : "#{prefix}.image."
        super pref
      end
    end
  end
end
