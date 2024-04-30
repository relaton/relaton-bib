module RelatonBib
  module Element
    module Media
      include ToString

      # @return [String]
      attr_reader :id, :src, :mimetype

      # @return [String, nil]
      attr_reader :filename, :alt, :title, :longdesc

      #
      # Initializes a new instance of media element.
      #
      # @param [String] id
      # @param [String] src any URI
      # @param [String] mimetype
      # @param [String, nil] filename
      # @param [String, nil] alt
      # @param [String, nil] title
      # @param [String, nil] longdesc any URI
      #
      def initialize(id:, src:, mimetype:, **args)
        super if defined? super
        @id = id
        @src = src
        @mimetype = mimetype
        @filename = args[:filename]
        @alt = args[:alt]
        @title = args[:title]
        @longdesc = args[:longdesc]
      end

      def to_xml(builder) # rubocop:disable Metics/AbcSize
        builder.parent[:id] = id
        builder.parent[:src] = src
        builder.parent[:mimetype] = mimetype
        builder.parent[:filename] = filename if filename
        super builder if defined? super
        builder.parent[:alt] = alt if alt
        builder.parent[:title] = title if title
        builder.parent[:longdesc] = longdesc if longdesc
      end

      #
      # Converts the Image object to a hash representation.
      #
      # @return [Hash] The hash representation of the Image object.
      #
      def to_h # rubocop:disable Metrics/AbcSize
        hash = { "id" => id, "src" => src, "mimetype" => mimetype }
        hash["filename"] = filename if filename
        hash.merge! super if defined? super
        hash["alt"] = alt if alt
        hash["title"] = title if title
        hash["longdesc"] = longdesc if longdesc
        hash
      end

      #
      # Converts the image object to AsciiBib format.
      #
      # @param prefix [String] The prefix to be added to the AsciiBib output.
      #
      # @return [String] The image object converted to AsciiBib format.
      #
      def to_asciibib(prefix = "") # rubocop:disable Metrics/AbcSize
        out = "#{prefix}id:: #{id}\n"
        out += "#{prefix}src:: #{src}\n"
        out += "#{prefix}mimetype:: #{mimetype}\n"
        out += "#{prefix}filename:: #{filename}\n" if filename
        out += super if defined? super
        out += "#{prefix}alt:: #{alt}\n" if alt
        out += "#{prefix}title:: #{title}\n" if title
        out += "#{prefix}longdesc:: #{longdesc}\n" if longdesc
        out
      end
    end

    module MediaSize
      # @return [String, nil]
      attr_reader :width, :height

      #
      # @param [String, nil] width integer in pixels or "auto"
      # @param [String, nil] height integer in pixels or "auto"
      #
      def initialize(**args)
        @width = args[:width]
        @height = args[:height]
      end

      def to_xml(builder)
        builder.parent[:width] = width if width
        builder.parent[:height] = height if height
        super builder if defined? super
      end

      #
      # Converts the Image object to a hash representation.
      #
      # @return [Hash] The hash representation of the Image object.
      #
      def to_h
        hash = {}
        hash["width"] = width if width
        hash["height"] = height if height
        hash
      end

      #
      # Converts the image object to AsciiBib format.
      #
      # @param prefix [String] The prefix to be added to the AsciiBib output.
      #
      # @return [String] The image object converted to AsciiBib format.
      #
      def to_asciibib(prefix = "")
        out = ""
        out += "#{prefix}width:: #{width}\n" if width
        out += "#{prefix}height:: #{height}\n" if height
        out
      end
    end

    class Audio
      include Base
      include Media

      # @!attribute [r] content
      #   @return [Array<RelatonBib::Element::Altsource>]

      #
      # Converts the image object to XML format.
      #
      # @param [Nokogiri::XML::Builder] builder The XML builder object.
      #
      # @return [void]
      #
      def to_xml(builder)
        builder.audio { |b| super b }
      end
    end

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

    class Video
      include MediaSize
      include Base
      include Media

      # @!attribute [r] content
      #   @return [Array<RelatonBib::Element::Altsource>]

      def to_xml(builder)
        builder.video { |b| super b }
      end

      # def to_h
      #   hash = super
      #   hash["content"] = content.map(&:to_h)
      #   hash
      # end

      # def to_asciibib(prefix = "")
      #   pref = prefix.empty? ? "video." : "#{prefix}.video."
      #   out = super pref
      #   content.each { |c| out += c.to_asciibib(pref) }
      #   out
      # end
    end
  end
end
