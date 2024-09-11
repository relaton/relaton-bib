# frozen_string_literal: true

module Relaton
  module Bib
    # Document status.
    class Status
      # @return [Relaton::Bib::Status::Stage]
      attr_accessor :stage

      # @return [Relaton::Bib::Status::Stage, nil]
      attr_accessor :substage

      # @return [String, nil]
      attr_accessor :iteration

      # @param stage [String, Hash, Relaton::Bib::Status::Stage]
      # @param substage [String, Hash, nil, Relaton::Bib::Status::Stage]
      # @param iteration [String, nil]
      def initialize(stage:, substage: nil, iteration: nil)
        @stage = stage_new stage
        @substage = stage_new substage
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

      # @param prefix [String]
      # @return [String]
      def to_asciibib(prefix = "")
        pref = prefix.empty? ? prefix : "#{prefix}."
        out = "#{pref}docstatus.stage:: #{stage.value}\n"
        out += "#{pref}docstatus.substage:: #{substage.value}\n" if substage
        out += "#{pref}docstatus.iteration:: #{iteration}\n" if iteration
        out
      end

      private

      # @param stg [Relaton::Bib::Status::Stage, Hash, String, nil]
      # @return [Relaton::Bib::Status::Stage]
      def stage_new(stg)
        case stg
        when Stage then stg
        when Hash then self.class::Stage.new(**stg)
        when String then self.class::Stage.new(value: stg)
        end
      end

      class Stage
        # @return [String]
        attr_reader :value

        # @return [String, nil]
        attr_reader :abbreviation

        # @param value [String]
        # @param abbreviation [String, nil]
        def initialize(value:, abbreviation: nil)
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
end
