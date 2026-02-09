module Relaton
  module Bib
    module Converter
      module BibXml
        class ToRfcxmlReferencegroup
          def initialize(item, include_keywords: true)
            @item = item
            @include_keywords = include_keywords
          end

          def transform
            Rfcxml::V3::Referencegroup.new(
              anchor: create_anchor,
              target: create_target,
              reference: build_references,
            )
          end

          private

          def build_references
            @item.relation&.each_with_object([]) do |rel, refs|
              next unless rel.type == "includes"

              converter = ToRfcxml.new(
                rel.bibitem, include_keywords: @include_keywords
              )
              refs << converter.transform
            end
          end

          def create_anchor
            docid = @item.docidentifier.detect(&:primary) ||
              @item.docidentifier[0]
            return unless docid

            id = docid.content.to_s
            id.sub(/^(RFC|BCP|FYI|STD) /, '\1').sub(/^\w+\./, "")
          end

          def create_target
            target = @item.source.detect { |l| l.type.casecmp("src").zero? } ||
              @item.source.detect { |l| l.type.casecmp("doi").zero? }
            return unless target

            target.content.to_s
          end
        end
      end
    end
  end
end
