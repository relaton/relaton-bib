require "addressable"

module RelatonBib
  # Typed URI
  class TypedUri
    # @return [String, nil]
    attr_reader :type, :language, :script, :locale

    # @return [Addressable::URI]
    attr_reader :content

    # @param content [String] URL
    # @param type [String, nil] src/obp/rss
    # @param language [String, nil] language code Iso639 (optional) (default: nil)
    # @param script [String, nil] script code Iso15924 (optional) (default: nil)
    # @param loclae [String, nil] locale code (optional) (default: nil)
    def initialize(content:, type: nil, language: nil, script: nil, locale: nil)
      @type     = type
      @language = language
      @script   = script
      @locale   = locale
      @content  = Addressable::URI.parse content if content
    end

    # @param url [String]
    def content=(url)
      @content = Addressable::URI.parse url
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder) # rubocop:disable Metrics/AbcSize
      builder.text content.to_s
      builder.parent[:type] = type if type
      builder.parent[:language] = language if language
      builder.parent[:script] = script if script
      builder.parent[:locale] = locale if locale
    end

    # @return [Hash]
    def to_h # rubocop:disable Metrics/AbcSize
      hash = { "content" => content.to_s }
      hash["type"] = type.to_s if type
      hash["language"] = language if language
      hash["script"] = script if script
      hash["locale"] = locale if locale
      hash
    end

    # @param prefix [String]
    # @param count [Integer] number of links
    # @return [String]
    def to_asciibib(prefix = "", count = 1)
      # pref = prefix.empty? ? "link" : "#{prefix}.link"
      out = count > 1 ? "#{prefix}::\n" : ""
      out += "#{prefix}.type:: #{type}\n" if type
      out += "#{prefix}.content:: #{content}\n"
      out += "#{prefix}.language:: #{language}\n" if language
      out += "#{prefix}.script:: #{script}\n" if script
      out += "#{prefix}.locale:: #{locale}\n" if locale
      out
    end
  end
end
