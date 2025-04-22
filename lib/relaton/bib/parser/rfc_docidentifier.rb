module Relaton
  module Bib
    module Parser
      class RfcDocidentifier
        RFCPREFIXES = %w[RFC BCP FYI STD].freeze

        def initialize(reference)
          @reference = reference
        end

        def transform
          docids = [create_docid(@reference.anchor, primary: true)]
          create_internet_draft_id { |id| docids << id }
          docids + docid_from_sereies_info
        end

        def create_docid(id, primary: false) # , ver) # rubocop:disable Metrics/MethodLength
          pref, num = id_to_pref_num(id)
          if RFCPREFIXES.include?(pref)
            pid = "#{pref} #{num.sub(/^-?0+/, '')}"
            type = pubid_type id
          elsif %w[I-D draft].include?(pref)
            pid = "draft-#{num}"
            type = "Internet-Draft"
          else
            pid = pref ? "#{pref} #{num}" : id
            type = pubid_type id
          end
          Docidentifier.new(type: type, content: pid, primary: primary)
        end

        def pubid_type(id)
          id_to_pref_num(id)&.first
        end

        def id_to_pref_num(id)
          tn = /^(?<pref>I-D|draft|3GPP|W3C|[A-Z]{2,})[._-]?(?<num>.+)/.match id
          tn && tn.to_a[1..2]
        end

        def create_internet_draft_id
          return unless @reference.respond_to?(:front) && @reference.front

          si = internet_draft_series_info(@reference.front) || internet_draft_series_info(@reference)
          if si
            content = si.value
            yield Docidentifier.new(type: "Internet-Draft", content: content)
          end
        end

        def internet_draft_series_info(parent)
          (parent.series_info || []).find { |si| si.name == "Internet-Draft" }
        end

        def docid_from_sereies_info # rubocop:disable Metrics/CyclomaticComplexity
          return [] unless @reference.respond_to?(:front) && @reference.front

          si = (@reference.front.series_info || []) + (@reference.series_info || [])
          si.reduce([]) do |acc, s|
            next acc unless s.name.casecmp("doi").zero?

            acc << Docidentifier.new(type: "DOI", content: s.value)
          end
        end

        def create_docidentifier(**args) = Docidentifier.new(**args)
      end
    end
  end
end
