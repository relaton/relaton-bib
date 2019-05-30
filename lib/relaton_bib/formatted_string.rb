# frozen_string_literal: true

require "relaton_bib/localized_string"

module RelatonBib
  # Formatted string
  class FormattedString < LocalizedString
    FORMATS = %w[text/plain text/html application/docbook+xml
                 application/tei+xml text/x-asciidoc text/markdown
                 application/x-isodoc+xml].freeze

    # @return [String]
    attr_reader :format

    # @param content [String]
    # @param language [String] language code Iso639
    # @param script [String] script code Iso15924
    # @param format [String] the content type
    def initialize(content:, language: nil, script: nil, format: "text/plain")
      # if format && !FORMATS.include?(format)
      #   raise ArgumentError, %{Format "#{format}" is invalid.}
      # end

      super(content, language, script)
      @format = format
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.parent["format"] = format if format
      super
    end
  end
end
