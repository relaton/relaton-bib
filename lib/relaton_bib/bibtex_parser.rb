require "bibtex"
require "iso639"

module RelatonBib
  class BibtexParser
    class << self
      # @param bibtex [String]
      # @return [Hash{String=>RelatonBib::BibliographicItem}]
      def from_bibtex(bibtex) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        BibTeX.parse(bibtex).reduce({}) do |h, bt|
          h[bt.key] = BibliographicItem.new(
            id: bt.key,
            docid: fetch_docid(bt),
            fetched: fetch_fetched(bt),
            type: fetch_type(bt),
            title: fetch_title(bt),
            contributor: fetch_contributor(bt),
            date: fetch_date(bt),
            place: fetch_place(bt),
            biblionote: fetch_note(bt),
            relation: fetch_relation(bt),
            extent: fetch_extent(bt),
            edition: bt["edition"]&.to_s,
            series: fetch_series(bt),
            link: fetch_link(bt),
            language: fetch_language(bt),
            classification: fetch_classification(bt),
            keyword: fetch_keyword(bt),
          )
          h
        end
      end

      private

      # @param bibtex [BibTeX::Entry]
      # @return [Array<RelatonBib::DocumentIdentifier>]
      def fetch_docid(bibtex) # rubocop:disable Metrics/AbcSize
        docid = []
        docid << DocumentIdentifier.new(id: bibtex.isbn.to_s, type: "isbn") if bibtex["isbn"]
        docid << DocumentIdentifier.new(id: bibtex.lccn.to_s, type: "lccn") if bibtex["lccn"]
        docid << DocumentIdentifier.new(id: bibtex.issn.to_s, type: "issn") if bibtex["issn"]
        docid
      end

      # @param bibtex [BibTeX::Entry]
      # @return [String, NilClass]
      def fetch_fetched(bibtex)
        Date.parse(bibtex.timestamp.to_s) if bibtex["timestamp"]
      end

      # @param bibtex [BibTeX::Entry]
      # @return [String]
      def fetch_type(bibtex)
        case bibtex.type
        when :mastersthesis, :phdthesis then "thesis"
        when :conference then "inproceedings"
        when :misc then "standard"
        else bibtex.type.to_s
        end
      end

      # @param bibtex [BibTeX::Entry]
      # @return [Array<Hash>]
      def fetch_place(bibtex)
        bibtex["address"] ? [bibtex.address.to_s] : []
      end

      # @param bibtex [BibTeX::Entry]
      # @return [RelatonBib::TypedTitleStringCollection]
      def fetch_title(bibtex)
        title = []
        title << { type: "main", content: bibtex.title.to_s } if bibtex["title"]
        title << { type: "main", content: bibtex.subtitle.to_s } if bibtex["subtitle"]
        TypedTitleStringCollection.new title
      end

      # @param bibtex [BibTeX::Entry]
      # @return [Array<Hash>]
      def fetch_contributor(bibtex) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength
        contributor = []
        fetch_person(bibtex["author"]).each do |entity|
          contributor << { entity: entity, role: [{ type: "author" }] }
        end

        fetch_person(bibtex["editor"]).each do |entity|
          contributor << { entity: entity, role: [{ type: "editor" }] }
        end

        if bibtex["publisher"]
          contributor << { entity: { name: bibtex.publisher.to_s }, role: [{ type: "publisher" }] }
        end

        if bibtex["institution"]
          contributor << {
            entity: { name: bibtex.institution.to_s },
            role: [{ type: "distributor", description: ["sponsor"] }],
          }
        end

        if bibtex["organization"]
          contributor << {
            entity: { name: bibtex.organization.to_s },
            role: [{ type: "distributor", description: ["sponsor"] }],
          }
        end

        if bibtex["school"]
          contributor << {
            entity: { name: bibtex.school.to_s },
            role: [{ type: "distributor", description: ["sponsor"] }],
          }
        end
        contributor
      end

      # @param bibtex [BibTeX::Entry]
      # @return [Array<RelatonBib::Person>]
      def fetch_person(person)
        return [] unless person

        person.map do |name|
          parts = name.split ", "
          surname = LocalizedString.new parts.first
          fname = parts.size > 1 ? parts[1].split : []
          forename = fname.map { |fn| Forename.new content: fn }
          Person.new name: FullName.new(surname: surname, forename: forename)
        end
      end

      # @param bibtex [BibTeX::Entry]
      # @return [Array<Hash>]
      def fetch_date(bibtex)
        date = []
        if bibtex["year"]
          on = Date.new(bibtex.year.to_i, bibtex["month_numeric"]&.to_i || 1).to_s
          date << { type: "published", on: on }
        end

        if bibtex["urldate"]
          date << { type: "accessed", on: Date.parse(bibtex.urldate.to_s).to_s }
        end

        date
      end

      # @param bibtex [BibTeX::Entry]
      # @return [RelatonBib::BiblioNoteCollection]
      def fetch_note(bibtex)
        bibtex.select do |k, _v|
          %i[annote howpublished comment note content].include? k
        end.reduce(BiblioNoteCollection.new([])) do |mem, note|
          type = case note[0]
                 when :note then nil
                 when :content then "tableOfContents"
                 else note[0].to_s
                 end
          mem << BiblioNote.new(type: type, content: note[1].to_s)
        end
      end

      # @param bibtex [BibTeX::Entry]
      # @return [Array<Hash>]
      def fetch_relation(bibtex)
        return [] unless bibtex["booktitle"]

        ttl = TypedTitleString.new(type: "main", content: bibtex.booktitle.to_s)
        title = TypedTitleStringCollection.new [ttl]
        [{ type: "partOf", bibitem: BibliographicItem.new(title: title) }]
      end

      # @param bibtex [BibTeX::Entry]
      # @return [Array<RelatonBib::BibItemLocality>]
      def fetch_extent(bibtex) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
        bibtex.select do |k, _v|
          %i[chapter pages volume].include? k
        end.reduce([]) do |mem, loc|
          if loc[0] == :pages
            type = "page"
            from, to = loc[1].to_s.split "-"
          else
            type = loc[0].to_s
            from = loc[1].to_s
            to = nil
          end
          mem << BibItemLocality.new(type, from, to)
        end
      end

      # @param bibtex [BibTeX::Entry]
      # @return [Array<RelatonBib::Series>]
      def fetch_series(bibtex) # rubocop:disable Metrics/MethodLength
        series = []
        if bibtex["journal"]
          series << Series.new(
            type: "journal",
            title: TypedTitleString.new(content: bibtex.journal.to_s),
            number: bibtex["number"]&.to_s
          )
        end

        if bibtex["series"]
          title = TypedTitleString.new content: bibtex.series.to_s
          series << Series.new(title: title)
        end
        series
      end

      # @param bibtex [BibTeX::Entry]
      # @return [Array<RelatonBib::TypedUri>]
      def fetch_link(bibtex) # rubocop:disable Metrics/AbcSize
        link = []
        link << TypedUri.new(type: "src", content: bibtex.url.to_s) if bibtex["url"]
        link << TypedUri.new(type: "doi", content: bibtex.doi.to_s) if bibtex["doi"]
        link << TypedUri.new(type: "file", content: bibtex.file2.to_s) if bibtex["file2"]
        link
      end

      # @param bibtex [BibTeX::Entry]
      # @return [Array<String>]
      def fetch_language(bibtex)
        return [] unless bibtex["language"]

        [Iso639[bibtex.language.to_s].alpha2]
      end

      # @param bibtex [BibTeX::Entry]
      # @return [RelatonBib::Classification, NilClass]
      def fetch_classification(bibtex)
        cls = []
        cls << Classification.new(type: "type", value: bibtex["type"].to_s) if bibtex["type"]
        # cls << Classification.new(type: "keyword", value: bibtex.keywords.to_s) if bibtex["keywords"]
        if bibtex["mendeley-tags"]
          cls << Classification.new(type: "mendeley", value: bibtex["mendeley-tags"].to_s)
        end
        cls
      end

      # @param bibtex [BibTeX::Entry]
      # @return [Array<String>]
      def fetch_keyword(bibtex)
        bibtex["keywords"]&.split(", ") || []
      end
    end
  end
end
