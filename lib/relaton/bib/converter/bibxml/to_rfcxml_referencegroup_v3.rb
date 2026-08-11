module Relaton
  module Bib
    module Converter
      module BibXml
        #
        # Strict RFC 7991 flavour of {ToRfcxmlReferencegroup}: members are
        # rendered by {ToRfcxmlV3}, and every one of them gets an anchor,
        # which the v3 grammar makes mandatory on `<reference>`.
        #
        class ToRfcxmlReferencegroupV3 < ToRfcxmlReferencegroup
          private

          # <referencegroup> needs an anchor just as much as its members do,
          # so fall back past the docidentifier the parent relies on.
          def create_anchor
            anchor = super || @item.docnumber || @item.id
            anchor && anchor.to_s.strip.gsub(/\s+/, ".")
          end

          def build_references
            included_items.each_with_index.map do |item, idx|
              ref = ToRfcxmlV3.new(item, include_keywords: @include_keywords)
                .transform
              ref.anchor = member_anchor(idx) if ref.anchor.to_s.empty?
              ref
            end
          end

          def included_items
            @item.relation.select { |rel| rel.type == "includes" }
              .map(&:bibitem)
          end

          def member_anchor(idx)
            "#{create_anchor || 'reference'}_#{idx + 1}"
          end
        end
      end
    end
  end
end
