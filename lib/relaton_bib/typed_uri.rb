require "addressable"

module RelatonBib
  # Typed URI
  class TypedUri
    # @return [Symbol] :src/:obp/:rss
    attr_reader :type
    # @retutn [URI]
    attr_reader :content

    # @param type [String] src/obp/rss
    # @param content [String]
    def initialize(type:, content:)
      @type    = type
      @content = Addressable::URI.parse content if content
    end

    def to_xml(builder)
      builder.uri(content.to_s, type: type)
    end
  end
end