require_relative "rfc_shared"
require_relative "rfc_contacts"
require_relative "rfc_person"
require_relative "rfc_organization"
require_relative "rfc_docidentifier"

module Relaton
  module Bib
    module Parser
      class RfcReference
        include RfcShared

        def initialize(reference)
          @reference = reference
        end

        def self.from_xml(xml)
          reference = Rfcxml::V3::Reference.from_xml xml
          new(reference).transform
        end

        def transform # rubocop:disable Metrics/MethodLength
          ItemData.new(
            docnumber: @reference.anchor.sub(/^\w+\./, ""),
            type: "standard",
            docidentifier: RfcDocidentifier.new(@reference).transform,
            status: status,
            language: ["en"],
            script: ["Latn"],
            source: source,
            title: title,
            formattedref: formattedref,
            abstract: abstract,
            contributor: contributor,
            date: date,
            series: series,
            keyword: keyword,
            ext: ext,
          )
        end

        def status
          si = @reference.front.series_info&.find(&:status) || @reference.series_info&.status
          return unless si

          stage = Status::Stage.new(content: si.status)
          Status.new(stage: stage)
        end

        def title
          [Title.new(content: @reference.front.title.content, language: "en", script: "Latn")]
        end

        def formattedref
          return if @reference.front.title

          @reference.anchor
        end

        def abstract
          return [] unless @reference.front.abstract

          @reference.front.abstract.t.map do |t|
            LocalizedMarkedUpString.new(content: t.content, language: "en", script: "Latn")
          end
        end

        def contributor
          (@reference.front.author || []).reduce([]) do |acc, author|
            p = person(author)
            o = organization(author)
            next acc unless p || o

            acc << Contributor.new(person: p, organization: o, role: [contributor_role(author)])
          end
        end

        def contributor_role(author)
          type = author.role || "author"
          Contributor::Role.new(type: type)
        end

        def person(author) = RfcPerson.transform(author)
        def organization(author) = RfcOrganization.transform(author)

        def date # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
          dt = @reference.front&.date
          return [] unless dt || dt.year || dt.month || dt.day

          dparts = [dt.year, month_to_num(dt.month), dt.day].compact.reject(&:empty?)
          at = dt.content.empty? ? dparts.join("-") : dt.content
          [Date.new(type: "published", at: at)]
        end

        def month_to_num(month)
          return unless month

          ::Date::MONTHNAMES.index(month.capitalize).to_s
        end

        def series # rubocop:disable Metrics/CyclomaticComplexity
          ((@reference.series_info || []) + (@reference.front.series_info || [])).map do |si|
            next if si.name == "DOI" || si.stream || si.status

            t = Title.new(content: si.name, language: "en", script: "Latn")
            Series.new(title: [t], number: si.value, type: "main")
          end.compact
        end

        def keyword
          (@reference.front.keyword || []).map do |kw|
            taxon = LocalizedString.new(content: kw.content, language: "en", script: "Latn")
            Keyword.new(taxon: [taxon])
          end
        end

        def ext
          eg = editorialgroup
          dt = doctype
          return unless eg || dt

          Bib::Ext.new editorialgroup: eg, doctype: dt
        end

        def editorialgroup
          return unless @reference.front.workgroup

          tc = @reference.front.workgroup.map { |wg| WorkGroup.new content: wg.content }
          EditorialGroup.new(technical_committee: tc) if tc.any?
        end

        def doctype
          type =  case @reference.anchor
                  when /I-D/ then "internet-draft"
                  when /IEEE/ then "ieee"
                  else "rfc"
                  end
          Doctype.new content: type
        end
      end
    end
  end
end
