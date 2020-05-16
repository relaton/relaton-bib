# frozen_string_literal: true

require "relaton_bib/localized_string"

module RelatonBib
  # Document status.
  class DocumentStatus
    # @return [String]
    attr_reader :stage

    # @return [String, NilClass]
    attr_reader :substage

    # @return [String, NilClass]
    attr_reader :iteration

    # @param stage [String, RelatonBib::DocumentStatus::Stage]
    # @param substage [String, NilClass, RelatonBib::DocumentStatus::Stage]
    # @param iteration [String, NilClass]
    def initialize(stage:, substage: nil, iteration: nil)
      @stage = stage.is_a?(Stage) ? stage : Stage.new(stage)
      @substage = substage.is_a?(Stage) ? substage : Stage.new(substage)
      @iteration = iteration
    end

    # @param [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.status do
        # FormattedString.instance_method(:to_xml).bind(status).call builder
        builder.stage { |b| stage.to_xml b }
        builder.substage { |b| substage.to_xml b } if substage
        builder.iteration iteration unless iteration.to_s.empty?
      end
    end

    # @return [Hash]
    def to_hash
      hash = { "stage" => stage.to_hash }
      hash["substage"] = substage.to_hash if substage
      hash["iteration"] = iteration if iteration
      hash
    end

    class Stage
      # @return [String]
      attr_reader :value

      # @return [String, NilClass]
      attr_reader :abbreviation

      # @parma value [String]
      # @param abbreviation [String, NilClass]
      def initialize(value, abbreviation = nil)
        @value = value
        @abbreviation = abbreviation
      end

      # @param [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.parent[:abbreviation] = abbreviation if abbreviation
        builder.text value
      end

      # @return [Hash]
      def to_hash
        hash = { "value" => value }
        hash["abbreviation"] = abbreviation if abbreviation
        hash
      end
    end
  end
end
