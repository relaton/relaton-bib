module Relaton
  module Bib
    module Converter
      module BibXml
        class FromRfcxmlReferencegroup
          include NamespaceHelper

          def initialize(reference)
            @reference = reference
          end

          def transform
            namespace::ItemData.new(
              docnumber: @reference.anchor.sub(/^\w+\./, ""),
              type: "standard",
              docidentifier: docidentifiers,
              source: source,
              relation: relation,
            )
          end

          private

          def docidentifiers
            [create_docid(@reference.anchor, primary: true)]
          end

          def create_docid(id, primary: false) # rubocop:disable Metrics/MethodLength
            pref, num = id_to_pref_num(id)
            if RFCPREFIXES.include?(pref)
              pid = "#{pref} #{num.sub(/^-?0+/, '')}"
              type = pubid_type(id)
            elsif %w[I-D draft].include?(pref)
              pid = "draft-#{num}"
              type = "Internet-Draft"
            else
              pid = pref ? "#{pref} #{num}" : id
              type = pubid_type(id)
            end
            Docidentifier.new(type: type, content: pid, primary: primary)
          end

          def pubid_type(id)
            id_to_pref_num(id)&.first
          end

          def id_to_pref_num(id)
            tn = FromRfcxml::PREF_NUM_RE.match id
            tn && tn.to_a[1..2]
          end

          def source
            s = []
            if @reference.target
              s << Uri.new(type: "src",
                           content: @reference.target)
            end
            s
          end

          def relation
            (@reference.reference || []).map do |ref|
              item = namespace::Converter::BibXml::FromRfcxml.new(ref).transform
              Relation.new(type: "includes", bibitem: item)
            end
          end
        end
      end
    end
  end
end
