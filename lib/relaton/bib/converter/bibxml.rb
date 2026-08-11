require_relative "bibxml/to_rfcxml"
require_relative "bibxml/to_rfcxml_referencegroup"
require_relative "bibxml/to_rfcxml_v3"
require_relative "bibxml/to_rfcxml_referencegroup_v3"
require_relative "bibxml/from_rfcxml"
require_relative "bibxml/from_rfcxml_referencegroup"

module Relaton
  module Bib
    module Converter
      module BibXml
        ORGNAMES = {
          "IEEE" => "Institute of Electrical and Electronics Engineers",
          "W3C" => "World Wide Web Consortium",
          "3GPP" => "3rd Generation Partnership Project",
        }.freeze

        RFCPREFIXES = %w[RFC BCP FYI STD].freeze

        # Forward: ItemData -> Rfcxml model
        #
        # @param v3 [Boolean] emit strict RFC 7991 (xml2rfc v3) instead of the
        #   BibXML shape the relaton data fetchers publish
        # @param anchor [String, nil] anchor to use instead of the one derived
        #   from the item's docnumber/docidentifier
        def self.from_item(item, include_keywords: true, v3: false, anchor: nil) # rubocop:disable Naming/MethodParameterName
          klass = if v3 then v3_converter(item)
                  elsif bcp?(item) then ToRfcxmlReferencegroup
                  else ToRfcxml
                  end
          klass.new(item, include_keywords: include_keywords,
                          anchor: anchor).transform
        end

        def self.v3_converter(item)
          if item.relation.any? { |rel| rel.type == "includes" }
            ToRfcxmlReferencegroupV3
          else ToRfcxmlV3
          end
        end
        private_class_method :v3_converter

        def self.bcp?(item) # rubocop:disable Metrics/CyclomaticComplexity
          item.docnumber&.match(/^BCP/) ||
            (item.docidentifier.detect(&:primary) ||
              item.docidentifier[0])&.content&.to_s&.include?("BCP")
        end
        private_class_method :bcp?

        # Reverse: XML string -> ItemData
        def self.to_item(xml)
          if xml.include?("<referencegroup") || xml.include?("<Referencegroup")
            referencegroup = Rfcxml::V3::Referencegroup.from_xml(xml)
            FromRfcxmlReferencegroup.new(referencegroup).transform
          else
            reference = Rfcxml::V3::Reference.from_xml(xml)
            FromRfcxml.new(reference).transform
          end
        end
      end
    end
  end
end
