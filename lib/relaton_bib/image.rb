module RelatonBib
  class Image
    # @return [String]
    attr_reader :id, :src, :mimetype, :filename, :width, :height, :alt, :title, :longdesc

    #
    # Initializes a new Image object.
    #
    # @param id [String] the ID of the image
    # @param src [String] the source URL of the image
    # @param mimetype [String] the MIME type of the image
    # @param args [Hash] additional arguments
    # @option args [String] :filename the filename of the image
    # @option args [String] :width the width of the image
    # @option args [String] :height the height of the image
    # @option args [String] :alt the alternative text for the image
    # @option args [String] :title the title of the image
    # @option args [String] :longdesc the long description of the image
    #
    def initialize(id:, src:, mimetype:, **args)
      @id = id
      @src = src
      @mimetype = mimetype
      @filename = args[:filename]
      @width = args[:width]
      @height = args[:height]
      @alt = args[:alt]
      @title = args[:title]
      @longdesc = args[:longdesc]
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
        builder.parent[:id] = id
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
      hash = { "image" => { "id" => id, "src" => src, "mimetype" => mimetype } }
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
      out = "#{pref}id:: #{id}\n"
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
