module RelatonBib
  class Medium
    # @return [String, nil]
    attr_reader :content, :genre, :form, :carrier, :size, :scale

    #
    # Initialize a Medium object.
    #
    # @param content [String, nil] content of the medium
    # @param genre [String, nil] genre of the medium
    # @param form [String, nil] form of the medium
    # @param carrier [String, nil] carrier of the medium
    # @param size [String, nil] size of the medium
    # @param scale [String, nil]
    #
    def initialize(**args)
      @content = args[:content]
      @genre   = args[:genre]
      @form    = args[:form]
      @carrier = args[:carrier]
      @size    = args[:size]
      @scale   = args[:scale]
    end

    #
    # Render Medium object to XML.
    #
    # @param builder [Nokogiri::XML::Builder]
    #
    def to_xml(builder) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      builder.medium do
        builder.content content if content
        builder.genre genre if genre
        builder.form form if form
        builder.carrier carrier if carrier
        builder.size size if size
        builder.scale scale if scale
      end
    end

    #
    # Render Medium object to hash.
    #
    # @return [Hash]
    #
    def to_hash # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      hash = {}
      hash["content"] = content if content
      hash["genre"] = genre if genre
      hash["form"] = form if form
      hash["carrier"] = carrier if carrier
      hash["size"] = size if size
      hash["scale"] = scale if scale
      hash
    end

    #
    # Render Medium object to AsciiBib.
    #
    # @param prefix [String]
    #
    # @return [String]
    #
    def to_asciibib(prefix = "") # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      pref = prefix.empty? ? "medium." : "#{prefix}.medium."
      out = ""
      out += "#{pref}content:: #{content}\n" if content
      out += "#{pref}genre:: #{genre}\n" if genre
      out += "#{pref}form:: #{form}\n" if form
      out += "#{pref}carrier:: #{carrier}\n" if carrier
      out += "#{pref}size:: #{size}\n" if size
      out += "#{pref}scale:: #{scale}\n" if scale
      out
    end
  end
end
