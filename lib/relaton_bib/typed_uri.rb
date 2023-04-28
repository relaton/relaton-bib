require "addressable"

module RelatonBib
  # Typed URI
  class TypedUri
    # @return [String, nil]
    attr_reader :type, :language, :script
    # @retutn [Addressable::URI]
    attr_reader :content

    # @param content [String] URL
    # @param type [String, nil] src/obp/rss
    # @param language [String, nil] language code Iso639 (optional) (default: nil)
    # @param script [String, nil] script code Iso15924 (optional) (default: nil)
    def initialize(content:, type: nil, language: nil, script: nil)
      @type     = type
      @language = language
      @script   = script
      @content  = Addressable::URI.parse content if content
    end

    # @param url [String]
    def content=(url)
      @content = Addressable::URI.parse url
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      doc = builder.uri content.to_s
      doc[:type] = type if type
      doc[:language] = language if language
      doc[:script] = script if script
    end

    # @return [Hash]
    def to_hash
      hash = { "content" => content.to_s }
      hash["type"] = type.to_s if type
      hash["language"] = language if language
      hash["script"] = script if script
      hash
    end

    # @param prefix [String]
    # @param count [Integer] number of links
    # @return [String]
    def to_asciibib(prefix = "", count = 1)
      pref = prefix.empty? ? "link" : "#{prefix}.link"
      out = count > 1 ? "#{pref}::\n" : ""
      out += "#{pref}.type:: #{type}\n" if type
      out += "#{pref}.content:: #{content}\n"
      out += "#{pref}.language:: #{language}\n" if language
      out += "#{pref}.script:: #{script}\n" if script
      out
    end
  end
end
