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
                     case c
                     when Hash
                       LocalizedString.new c[:content], c[:language], c[:script]
                     when String then LocalizedString.new c
                     else c
                     end
                   end
                 else content
                 end
    end

    # @return [String]
    def to_s
      content.is_a?(Array) ? content.first.to_s : content.to_s
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
        builder.parent.inner_html = encode content
      end
    end

    #
    # Encode content.
    #
    # @param [String] cnt content
    #
    # @return [String] encoded content
    #
    def encode(cnt) # rubocop:disable Metrics/MethodLength
      regex = /(?<prf>.*?)(?<xml><(?<tag>\w+)>.*<\/\k<tag>>)(?<sfx>.*)/m
      if cnt.match(regex)
        prf = Regexp.last_match(:prf).lstrip
        xml = Regexp.last_match[:xml]
        sfx = Regexp.last_match(:sfx).rstrip
        parts = xml.scan(/\s*<(?<tago>\w+)>(?<cnt1>.*?)(?=<\/?\w+>)|(?<cnt2>.*?)<\/(?<tagc>\w+)>/)
        out = scan_xml parts
        "#{escp(prf)}#{out}#{escp(sfx)}"
      else
        escp cnt
      end
    end

    #
    # Scan XML and escape HTML entities.
    #
    # @param [Array<Array<String,nik>>] parts XML parts
    #
    # @return [String] output string
    #
    def scan_xml(parts) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/MethodLength
      return "" unless parts.any? && parts.first[0]

      tago, cnt1, = parts.shift
      if tago && tago == parts.first[3]
        _, _, cnt2, tagc = parts.shift
        "<#{tago}>#{escp(cnt1)}#{escp(cnt2)}</#{tagc}>"
      elsif tago
        inr = scan_xml parts
        _, _, cnt2, tagc = parts.shift
        if tago == tagc
          "<#{tago}>#{escp(cnt1)}#{inr}#{escp(cnt2)}</#{tagc}>"
        else
          "#{escp("<#{tago}>#{cnt1}")}#{inr}#{escp("#{cnt2}</#{tagc}>")}"
        end
      end + scan_xml(parts)
    end

    #
    # Escope HTML entities.
    #
    # @param [String] str input string
    #
    # @return [String] output string
    #
    def escp(str)
      HTMLEntities.new.encode str
    end

    # @return [Hash]
    def to_hash # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      if content.is_a? String
        return content unless language || script

        hash = { "content" => content }
        hash["language"] = single_element_array(language) if language&.any?
        hash["script"] = single_element_array(script) if script&.any?
        hash
      else content&.map &:to_hash
      end
    end

    # @param prefix [String]
    # @param count [Integer] number of elements
    # @return [String]
    def to_asciibib(prefix = "", count = 1, has_attrs = false) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/MethodLength
      pref = prefix.empty? ? prefix : "#{prefix}."
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
