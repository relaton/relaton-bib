# frozen_string_literal: true

module RelatonBib
  # Localized string.
  class LocalizedString
    # @return [Array<String>] language Iso639 code
    attr_reader :language

    # @return [Array<String>] script Iso15924 code
    attr_reader :script

    # @return [String]
    attr_reader :content

    # @param content [String]
    # @param language [String] language code Iso639
    # @param script [String] script code Iso15924
    def initialize(content, language = nil, script = nil)
      @language = []
      @language << language if language
      @script = []
      @script << script if script
      @content = content
    end

    # @return [String]
    def to_s
      content
    end

    # @return [TrueClass, FalseClass]
    def empty?
      content.empty?
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      return unless content

      builder.parent["language"] = language.join(",") if language.any?
      builder.parent["script"]   = script.join(",") if script.any?
      builder.text content
    end
  end
end
