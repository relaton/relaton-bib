module RelatonBib
  module DocumentIdentifierBase
    # @return [String, nil]
    attr_reader :type, :scope, :language, :script

    # @param type [Boolean, nil]
    attr_reader :primary

    # @param id [String]
    # @param type [String, nil]
    # @param scope [String, nil]
    # @param primary [Bolean, nil]
    # @param language [String, nil]
    def initialize(**args)
      @id       = args[:id]
      @type     = args[:type]
      @scope    = args[:scope]
      @primary  = args[:primary]
      @language = args[:language]
      @script   = args[:script]
    end

    # @return [Hash]
    def to_hash # rubocop:disable Metrics/AbcSize
      hash = { "id" => id }
      hash["type"] = type if type
      hash["scope"] = scope if scope
      hash["primary"] = primary if primary
      hash["language"] = language if language
      hash["script"] = script if script
      hash
    end

    # @param prefix [String]
    # @param count [Integer] number of docids
    # @return [String]
    def to_asciibib(prefix = "", count = 1) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize
      pref = prefix.empty? ? prefix : "#{prefix}."
      return "#{pref}docid:: #{id}\n" unless type || scope

      out = count > 1 ? "#{pref}docid::\n" : ""
      out += "#{pref}docid.type:: #{type}\n" if type
      out += "#{pref}docid.scope:: #{scope}\n" if scope
      out += "#{pref}docid.primary:: #{primary}\n" if primary
      out += "#{pref}docid.language:: #{language}\n" if language
      out += "#{pref}docid.script:: #{script}\n" if script
      out + "#{pref}docid.id:: #{id}\n"
    end

    #
    # Add docidentifier xml element
    #
    # @param opts [Hash]
    # @option opts [Nokogiri::XML::Builder] :builder XML builder
    # @option opts [String] :lang language
    def to_xml(**opts) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      element = opts[:builder].docidentifier { |b| b.parent.inner_html = id(opts[:lang]) }
      element[:type] = type if type
      element[:scope] = scope if scope
      element[:primary] = primary if primary
      element[:language] = language if language
      element[:script] = script if script
    end
  end
end
