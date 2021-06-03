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
    def initialize(content, language = nil, script = nil) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      if content.is_a?(Array) && content.none?
        raise ArgumentError, "LocalizedString content is empty"
      end
      @language = language.is_a?(String) ? [language] : language
      @script = script.is_a?(String) ? [script] : script
      @content = if content.is_a?(Array)
                   content.map do |c|
                     if c.is_a?(Hash)
                       LocalizedString.new c[:content], c[:language], c[:script]
                     elsif c.is_a?(String)
                       LocalizedString.new c
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
    def to_xml(builder) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
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
    def to_hash # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      if content.is_a? String
        return content unless language || script

        hash = { "content" => content }
        hash["language"] = single_element_array(language) if language&.any?
        hash["script"] = single_element_array(script) if script&.any?
        hash
      else content.map &:to_hash
      end
    end

    # @param prefix [String]
    # @param count [Integer] number of elements
    # @return [String]
    def to_asciibib(prefix = "", count = 1, has_attrs = false) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/MethodLength
      pref = prefix.empty? ? prefix : prefix + "."
      if content.is_a? String
        unless language&.any? || script&.any? || has_attrs
          return "#{prefix}:: #{content}\n"
        end

        out = count > 1 ? "#{prefix}::\n" : ""
        out += "#{pref}content:: #{content}\n"
        language&.each { |l| out += "#{pref}language:: #{l}\n" }
        script&.each { |s| out += "#{pref}script:: #{s}\n" }
        out
      else
        content.map { |c| c.to_asciibib "#{pref}variant", content.size }.join
      end
    end
  end
end
