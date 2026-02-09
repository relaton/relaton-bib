require_relative "bibxml/to_rfcxml"
require_relative "bibxml/to_rfcxml_referencegroup"
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
        def self.from_item(item, include_keywords: true) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
          if bcp?(item)
            ToRfcxmlReferencegroup.new(
              item, include_keywords: include_keywords
            ).transform
          else
            ToRfcxml.new(
              item, include_keywords: include_keywords
            ).transform
          end
        end

        def self.bcp?(item) # rubocop:disable Metrics/CyclomaticComplexity
          item.docnumber&.match(/^BCP/) ||
            (item.docidentifier.detect(&:primary) ||
              item.docidentifier[0])&.content&.include?("BCP")
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
