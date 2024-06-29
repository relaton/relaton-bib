module Relaton
  module Bib
    class Title
      # ARGS = %i[content language script format].freeze

      # @return [String]
      attr_accessor :type, :language, :script, :locale

      # @param type [Relaton::Model::LocalizedMarkedUpString::Content]
      attr_reader :content

      # @param type [String]
      # @param content [String]
      # @param language [String]
      # @param script [String]
      # @param locale [String]
      def initialize(**args) # rubocop:disable Metrics/MethodLength
        @type = args[:type]
        self.content = args[:content]
        @language = args[:language]
        @script = args[:script]
        @locale = args[:locale]

      #   unless args[:title] || args[:content]
      #     raise ArgumentError, %{Keyword "title" or "content" should be passed.}
      #   end

      #   @type = args[:type]

      #   case args[:title]
      #   when FormattedString then @title = args[:title]
      #   when Hash then @title = FormattedString.new(**args[:title])
      #   else
      #     fsargs = args.select { |k, _v| ARGS.include? k }
      #     @title = FormattedString.new(**fsargs)
      #   end
      end

      def content=(content)
        @content = content.is_a?(String) ? Model::LocalizedMarkedUpString.from_xml(content) : content
      end

      #
      # Create TitleCollection from string
      #
      # @param title [String] title string
      # @param lang [String, nil] language code Iso639
      # @param script [String, nil] script code Iso15924
      # @param format [String] format text/html, text/plain
      #
      # @return [TitleCollection] collection of Title
      #
      def self.from_string(title, lang = nil, script = nil, format = "text/plain")
        types = %w[title-intro title-main title-part]
        ttls = split_title(title)
        tts = ttls.map.with_index do |p, i|
          next unless p

          new type: types[i], content: p, language: lang, script: script, format: format
        end.compact
        tts << new(type: "main", content: ttls.compact.join(" - "),
                  language: lang, script: script, format: format)
        TitleCollection.new tts
      end

      # @param title [String]
      # @return [Array<String, nil>]
      def self.split_title(title)
        ttls = title.sub(/\w\.Imp\s?\d+\u00A0:\u00A0/, "").split " - "
        case ttls.size
        when 0, 1 then [nil, ttls.first.to_s, nil]
        else intro_or_part ttls
        end
      end

      # @param ttls [Array<String>]
      # @return [Array<String, nil>]
      def self.intro_or_part(ttls)
        if /^(Part|Partie) \d+:/.match? ttls[1]
          [nil, ttls[0], ttls[1..].join(" -- ")]
        else
          parts = ttls.slice(2..-1)
          part = parts.join " -- " if parts.any?
          [ttls[0], ttls[1], part]
        end
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml
      #   builder.parent[:type] = type if type
      #   title.to_xml builder
        Model::Title.to_xml self
      end

      # @return [Hash]
      # def to_hash
      #   th = title.to_hash
      #   return th unless type

      #   th.merge "type" => type
      # end

      # @param prefix [String]
      # @param count [Integer] number of titles
      # @return [String]
      def to_asciibib(prefix = "", count = 1) # rubocop:disable Metrics/AbcSize
        pref = prefix.empty? ? prefix : "#{prefix}."
        out = count > 1 ? "#{pref}title::\n" : ""
        out += "#{pref}title.type:: #{type}\n" if type
        out += title.to_asciibib "#{pref}title", 1, !(type.nil? || type.empty?)
        out
      end
    end
  end
end
