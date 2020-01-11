module RelatonBib
  class TypedTitleString
    TITLE_TYPES = %w[alternative original unofficial subtitle main].freeze

    # @return [String]
    attr_reader :type

    # @return [RelatonBib::FormattedString]
    attr_reader :title

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength

    # @param type [String]
    # @param title [RelatonBib::FormattedString, Hash]
    # @param content [String]
    # @param language [String]
    # @param script [String]
    def initialize(**args)
      if args[:type] && !TITLE_TYPES.include?(args[:type])
        warn %{[relaton-bib] title type "#{args[:type]}" is invalid.}
      end

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
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

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
