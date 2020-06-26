module RelatonBib
  class TypedTitleString
    # @return [String]
    attr_reader :type

    # @return [RelatonBib::FormattedString]
    attr_reader :title

    # rubocop:disable Metrics/MethodLength

    # @param type [String]
    # @param title [RelatonBib::FormattedString, Hash]
    # @param content [String]
    # @param language [String]
    # @param script [String]
    def initialize(**args)
      unless args[:title] || args[:content]
        raise ArgumentError, %{Keyword "title" or "content" should be passed.}
      end

      @type = args[:type]

      if args[:title]
        @title = args[:title]
      else
        fsargs = args.select do |k, _v|
          %i[content language script format].include? k
        end
        @title = FormattedString.new(fsargs)
      end
    end
    # rubocop:enable Metrics/MethodLength

    # @param title [String]
    # @return [Array<self>]
    def self.from_string(title, lang = nil, script = nil)
      types = %w[title-intro title-main title-part]
      ttls = split_title(title)
      tts = ttls.map.with_index do |p, i|
        new type: types[i], content: p, language: lang, script: script if p
      end.compact
      tts << new(type: "main", content: ttls.compact.join(" - "),
                 language: lang, script: script)
    end

    # @param title [String]
    # @return [Array<String, nil>]
    def self.split_title(title)
      ttls = title.sub(/\w\.Imp\s?\d+\u00A0:\u00A0/, "").split " - "
      case ttls.size
      when 0, 1 then [nil, ttls.first.to_s, nil]
      else intro_or_part ttls
      # when 2, 3 then intro_or_part ttls
      # else [ttls[0], ttls[1], ttls[2..-1].join(" -- ")]
      end
    end

    # @param ttls [Array<String>]
    # @return [Array<Strin, nil>]
    def self.intro_or_part(ttls)
      if /^(Part|Partie) \d+:/ =~ ttls[1]
        [nil, ttls[0], ttls[1..-1].join(" -- ")]
      else
        parts = ttls.slice(2..-1)
        part = parts.join " -- " if parts.any?
        [ttls[0], ttls[1], part]
      end
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.parent[:type] = type if type
      title.to_xml builder
    end

    # @return [Hash]
    def to_hash
      th = title.to_hash
      return th unless type

      hash = { "type" => type }
      if th.is_a? String
        hash["content"] = th
      else
        hash.merge! th
      end
      hash
    end
  end
end
