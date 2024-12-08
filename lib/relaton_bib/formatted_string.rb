# frozen_string_literal: true

require "relaton_bib/localized_string"

module RelatonBib
  # Formatted string
  class FormattedString < LocalizedString
    FORMATS = %w[text/plain text/html application/docbook+xml
                 application/tei+xml text/x-asciidoc text/markdown
                 application/x-metanorma+xml].freeze

    # @return [String]
    attr_reader :format

    # @param content [String, Array<RelatonBib::LocalizedString>]
    # @param language [String, nil] language code Iso639
    # @param script [String, nil] script code Iso15924
    # @param format [String] the content type
    def initialize(content: "", language: nil, script: nil, format: "text/plain")
      # if format && !FORMATS.include?(format)
      #   raise ArgumentError, %{Format "#{format}" is invalid.}
      # end

      @format = format
      super(content, language, script)
    end

    def ==(other)
      super && format == other.format
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.parent["format"] = format if format
      super
    end

    #
    # Encode content.
    #
    # @param [String] cnt content
    #
    # @return [String] encoded content
    #
    def encode(cnt) # rubocop:disable Metrics/MethodLength
      return escp(cnt) unless format == "text/html"

      parts = cnt.scan(%r{
        <(?<tago>\w+)(?<attrs>[^>]*)> | # tag open
        </(?<tagc>\w+)> | # tag close
        (?<cmt><!--.*?-->) | # comment
        (?<cnt>.+?)(?=<|$) # content
        }x)
      scan_xml parts
    end

    #
    # Scan XML and escape HTML entities.
    #
    # @param [Array<Array<String,nil>>] parts XML parts
    #
    # @return [String] output string
    #
    def scan_xml(parts) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/MethodLength
      return "" unless parts.any?

      out = ""
      while parts.any? && (parts.first[3] || parts.first[4])
        _, _, _, cmt, cnt = parts.shift
        out += "#{cmt}#{escp(cnt)}"
      end
      unless out.empty?
        out += scan_xml(parts) if parts.any? && parts.first[0]
        return out
      end

      tago, attrs, tagc, = parts.shift
      out = if tago && attrs && attrs[-1] == "/"
              "<#{tago}#{attrs}>"
            elsif tago
              inr = scan_xml parts
              _, _, tagc, = parts.shift
              if tago == tagc
                "<#{tago}#{attrs}>#{inr}</#{tagc}>"
              else
                "#{escp("<#{tago}#{attrs}>")}#{inr}#{escp("</#{tagc}>")}"
              end
            end
      out += scan_xml(parts) if parts.any? && (parts.first[0] || parts.first[3] || parts.first[4])
      out
    end

    # @return [Hash]
    def to_hash
      hash = super
      return hash unless format

      hash = { "content" => hash } unless hash.is_a? Hash
      hash["format"] = format
      hash
    end

    # @param prefix [String]
    # @param count [Integer] number of elements
    # @return [String]
    def to_asciibib(prefix = "", count = 1, has_attrs = false)
      has_attrs ||= !(format.nil? || format.empty?)
      pref = prefix.empty? ? prefix : "#{prefix}."
      # out = count > 1 ? "#{prefix}::\n" : ""
      out = super
      out += "#{pref}format:: #{format}\n" if format
      out
    end

    #
    # Remove HTML tags except <em>, <strong>, <stem>, <sup>, <sub>, <tt>, <br>, <p>.
    # Replace <i> with <em>, <b> with <strong>.
    #
    # @param [String] str content
    #
    # @return [String] cleaned content
    #
    def cleanup(str)
      return str unless format == "text/html"

      str.gsub(/(?<=<)\w+:(?=\w+>)/, "").gsub(/(?<=<\/)\w+:(?=\w+>)/, "")
        .gsub(/<i>/, "<em>").gsub(/<\/i>/, "</em>")
        .gsub(/<b>/, "<strong>").gsub(/<\/b>/, "</strong>")
        .gsub(/<(?!\/?(em|strong|stem|sup|sub|tt|br\s?\/|p|ol|ul|li))[^\s!]\/?.*?>/i, "")
        .gsub(/\s+([.,:;!?<])/, "\\1").strip.squeeze(" ")
    end
  end
end
