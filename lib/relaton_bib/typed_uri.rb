require "addressable"

module RelatonBib
  # Typed URI
  class TypedUri
    # @return [Symbol] :src/:obp/:rss
    attr_reader :type
    # @retutn [URI]
    attr_reader :content

    # @param type [String, NilClass] src/obp/rss
    # @param content [String]
    def initialize(type: nil, content:)
      @type    = type
      @content = Addressable::URI.parse content if content
    end

    # @parma url [String]
    def content=(url)
      @content = Addressable::URI.parse url
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      doc = builder.uri content.to_s
      doc[:type] = type if type
    end

    # @return [Hash]
    def to_hash
      hash = { "content" => content.to_s }
      hash["type"] = type.to_s if type
      hash
    end
  end
end
