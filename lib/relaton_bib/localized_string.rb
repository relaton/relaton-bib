# frozen_string_literal: true

module RelatonBib
  # Localized string.
  class LocalizedString
    include RelatonBib

    # @return [Array<String>] language Iso639 code
    attr_reader :language

    # @return [Array<String>] script Iso15924 code
    attr_reader :script

    # @return [String, Array<RelatonBib::LocalizedString>]
    attr_accessor :content

    # @param content [String, Array<RelatonBib::LocalizedString>]
    # @param language [String] language code Iso639
    # @param script [String] script code Iso15924
    def initialize(content, language = nil, script = nil)
      unless content.is_a?(String) || content.is_a?(Array) &&
          (inv = content.reject { |c| c.is_a?(LocalizedString) || c.is_a?(Hash) }).
              none? && content.any?
        klass = content.is_a?(Array) ? inv.first.class : content.class
        raise ArgumentError, "invalid LocalizedString content type: #{klass}"
      end
      @language = language.is_a?(String) ? [language] : language
      @script = script.is_a?(String) ? [script] : script
      @content = if content.is_a?(Array)
                   content.map do |c|
                     if c.is_a?(Hash)
                       LocalizedString.new c[:content], c[:language], c[:script]
                     else c
                     end
                   end
                 else content
                 end
    end

    # @return [String]
    def to_s
      content.is_a?(String) ? content : content.first.to_s
    end

    # @return [TrueClass, FalseClass]
    def empty?
      content.empty?
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      return unless content

      if content.is_a?(Array)
        content.each { |c| builder.variant { c.to_xml builder } }
      else
        builder.parent["language"] = language.join(",") if language&.any?
        builder.parent["script"]   = script.join(",") if script&.any?
        builder.text content.encode(xml: :text)
      end
    end

    # @return [Hash]
    def to_hash
      if content.is_a? String
        return content unless language || script

        hash = { "content" => content }
        hash["language"] = single_element_array(language) if language&.any?
        hash["script"] = single_element_array(script) if script&.any?
        hash
      else content.map &:to_hash
      end
    end
  end
end
