require_relative "rfc_shared"

module Relaton
  module Bib
    module Parser
      # Class for transforming RFC ReferenceGroup to Relaton ReferenceGroup
      class RfcReferencegroup
        include RfcShared

        def initialize(reference)
          @reference = reference
        end

        #
        # Transform reference group from RFC ReferenceGroup to Relaton ReferenceGroup
        #
        # @param [Rfcxml::V3::ReferenceGroup] reference_group RFC ReferenceGroup
        #
        # @return [Relaton::Bib::ReferenceGroup]
        #
        def self.from_xml(xml) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
          reference = Rfcxml::V3::Referencegroup.from_xml xml
          new(reference).transform
        end

        def transform
          ItemData.new(
            docnumber: @reference.anchor.sub(/^\w+\./, ""),
            type: "standard",
            docidentifier: RfcDocidentifier.new(@reference).transform,
            source: source,
            relation: relation,
          )
        end

        def relation
          (@reference.reference || []).map do |ref|
            item = RfcReference.new(ref).transform
            Relation.new(type: "includes", bibitem: item)
          end
        end
      end
    end
  end
end
