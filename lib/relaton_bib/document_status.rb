# frozen_string_literal: true

require "relaton_bib/localized_string"

module RelatonBib
  # Dovument status.
  class DocumentStatus
    # @return [String]
    attr_reader :stage

    # @return [String, NilClass]
    attr_reader :substage

    # @return [String, NilClass]
    attr_reader :iteration

    # @param stage [String]
    # @param substage [String, NilClass]
    # @param iteration [String, NilClass]
    def initialize(stage:, substage: nil, iteration: nil)
      @stage = stage
      @substage = substage
      @iteration = iteration
    end

    # @param [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.status do
        # FormattedString.instance_method(:to_xml).bind(status).call builder
        builder.stage stage
        builder.substage substage if substage
        builder.iteration iteration unless iteration.to_s.empty?
      end
    end
  end
end
