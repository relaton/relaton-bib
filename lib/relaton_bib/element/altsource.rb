module RelatonBib
  module Element
    class Altsource
      # @return [String]
      attr_reader :src, :mimetype

      # @return [String, nil]
      attr_reader :filename

      #
      # Initialize altsource element.
      #
      # @param [String] src any URI
      # @param [String] mimetype
      # @param [String, nil] filename
      #
      def initialize(src:, mimetype:, filename: nil)
        @src = src
        @mimetype = mimetype
        @filename = filename
      end

      def to_xml(builder)
        node = builder.altsource(src: src, mimetype: mimetype)
        node[:filename] = filename if filename
      end
    end
  end
end
