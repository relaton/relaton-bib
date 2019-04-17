# frozen_string_literal: true

require "relaton_bib/localized_string"

module RelatonBib
  # Dovument status.
  class DocumentStatus
    # @return [RelatonBib::LocalizedString]
    attr_reader :status

    # @param status [RelatonBib::LocalizedString]
    def initialize(status)
      @status = status
    end

    # @param [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.status do
        # FormattedString.instance_method(:to_xml).bind(status).call builder
        status.to_xml builder
      end
    end
  end
end
