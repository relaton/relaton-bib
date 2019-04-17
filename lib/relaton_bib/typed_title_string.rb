module RelatonBib
  class TypedTitleString
    TITLE_TYPES = %w[alternative original unofficial subtitle main].freeze

    # @return [String]
    attr_reader :type

    # @return [RelatonBib::FormattedString]
    attr_reader :title

    # @param type [String]
    # @param title [RelatonBib::FormattedString, Hash]
    # @param content [String]
    # @param language [String]
    # @param script [String]
    def initialize(**args)
      if type && !TITLE_TYPES.include?(args[:type])
        raise ArgumentError, %{The type #{args[:type]} is invalid.}
      end

      unless args[:title] || args[:content]
        raise ArgumentError, %{Keyword "title" or "content" should be passed.}
      end

      @type = args[:type]

      if args[:title]
        @title = args[:title]
      else
        fsargs = args.select { |k, _v| %i[content language script format].include? k }
        @title = args.fetch :title, FormattedString.new(fsargs)
      end
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.parent[:type] = type if type
      title.to_xml builder
    end
  end
end
