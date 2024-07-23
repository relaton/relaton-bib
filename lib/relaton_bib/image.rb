module RelatonBib
  class Image
    # @return [String]
    attr_accessor :src, :mimetype

    # @return [String, nil]
    attr_accessor :id, :filename, :width, :height, :alt, :title, :longdesc

    #
    # Initializes a new Image object.
    #
    # @param src [String] the source URL of the image
    # @param mimetype [String] the MIME type of the image
    # @param args [Hash] additional arguments
    # @option id [String, nil] the ID of the image
    # @option args [String, nil] :filename the filename of the image
    # @option args [String, nil] :width the width of the image
    # @option args [String, nil] :height the height of the image
    # @option args [String, nil] :alt the alternative text for the image
    # @option args [String, nil] :title the title of the image
    # @option args [String, nil] :longdesc the long description of the image
    #
    def initialize(src:, mimetype:, **args)
      @src = src
      @mimetype = mimetype
      args.each { |k, v| send "#{k}=", v }
    end

    def ==(other)
      other.is_a?(Image) && id == other.id && src == other.src && mimetype == other.mimetype &&
        filename == other.filename && width == other.width && height == other.height &&
        alt == other.alt && title == other.title && longdesc == other.longdesc
    end

    #
    # Converts the image object to XML format.
    #
    # @param [Nokogiri::XML::Builder] builder The XML builder object.
    #
    # @return [void]
    #
    def to_xml(builder) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength
      builder.image do
        builder.parent[:id] = id if id
        builder.parent[:src] = src
        builder.parent[:mimetype] = mimetype
        builder.parent[:filename] = filename if filename
        builder.parent[:width] = width if width
        builder.parent[:height] = height if height
        builder.parent[:alt] = alt if alt
        builder.parent[:title] = title if title
        builder.parent[:longdesc] = longdesc if longdesc
      end
    end

    #
    # Converts the Image object to a hash representation.
    #
    # @return [Hash] The hash representation of the Image object.
    #
    def to_hash # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity
      hash = { "image" => { "src" => src, "mimetype" => mimetype } }
      hash["image"]["id"] = id if id
      hash["image"]["filename"] = filename if filename
      hash["image"]["width"] = width if width
      hash["image"]["height"] = height if height
      hash["image"]["alt"] = alt if alt
      hash["image"]["title"] = title if title
      hash["image"]["longdesc"] = longdesc if longdesc
      hash
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
      out = ""
      out += "#{pref}id:: #{id}\n" if id
      out += "#{pref}src:: #{src}\n"
      out += "#{pref}mimetype:: #{mimetype}\n"
      out += "#{pref}filename:: #{filename}\n" if filename
      out += "#{pref}width:: #{width}\n" if width
      out += "#{pref}height:: #{height}\n" if height
      out += "#{pref}alt:: #{alt}\n" if alt
      out += "#{pref}title:: #{title}\n" if title
      out += "#{pref}longdesc:: #{longdesc}\n" if longdesc
      out
    end
  end
end
