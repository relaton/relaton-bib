module Relaton
  module Bib
    class BibtexParser
      class << self
        # @param bibtex [String]
        # @return [Hash{String=>Relaton::Bib::ItemData}]
        def from_bibtex(bibtex) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
          BibTeX.parse(bibtex).reduce({}) do |h, bt|
            h[bt.key] = ItemData.new(
              id: bt.key,
              docidentifier: fetch_docid(bt),
              fetched: fetch_fetched(bt),
              type: fetch_type(bt),
              title: fetch_title(bt),
              contributor: fetch_contributor(bt),
              date: fetch_date(bt),
              place: fetch_place(bt),
              note: fetch_note(bt),
              relation: fetch_relation(bt),
              extent: fetch_extent(bt),
              edition: fetch_edition(bt),
              series: fetch_series(bt),
              source: fetch_link(bt),
              language: fetch_language(bt),
              classification: fetch_classification(bt),
              keyword: fetch_keyword(bt),
            )
            h
          end
        end

        private

        # @param bibtex [BibTeX::Entry]
        # @return [Array<Relaton::Bib::Docidentifier>]
        def fetch_docid(bibtex) # rubocop:disable Metrics/AbcSize
          docid = []
          docid << Docidentifier.new(content: bibtex.isbn.to_s, type: "isbn") if bibtex["isbn"]
          docid << Docidentifier.new(content: bibtex.lccn.to_s, type: "lccn") if bibtex["lccn"]
          docid << Docidentifier.new(content: bibtex.issn.to_s, type: "issn") if bibtex["issn"]
          docid
        end

        # @param bibtex [BibTeX::Entry]
        # @return [String, nil]
        def fetch_fetched(bibtex)
          ::Date.parse(bibtex.timestamp.to_s) if bibtex["timestamp"]
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
        # @return [Array<Relaton::Bib::Place>]
        def fetch_place(bibtex)
          bibtex["address"] ? [Place.new(formatted_place: bibtex.address.to_s)] : []
        end

        # @param bibtex [BibTeX::Entry]
        # @return [Relaton::Bib::TitleCollection]
        def fetch_title(bibtex)
          title = []
          title << Title.new(type: "main", content: bibtex.convert(:latex).title.to_s) if bibtex["title"]
          title << Title.new(type: "main", content: bibtex.convert(:latex).subtitle.to_s) if bibtex["subtitle"]
          title
        end

        # @param bibtex [BibTeX::Entry]
        # @return [Array<Relaton::Bib::Contributor>]
        def fetch_contributor(bibtex) # rubocop:disable Metrics/AbcSize
          contribs = []
          fetch_person(bibtex, "author") { |c| contribs << c }
          fetch_person(bibtex, "editor") { |c| contribs << c }

          fetch_org(bibtex["publisher"], "publisher") { |c| contribs << c }
          fetch_org(bibtex["institution"], "distributor", "sponsor") { |c| contribs << c }
          fetch_org(bibtex["organization"], "distributor", "sponsor") { |c| contribs << c }
          fetch_org(bibtex["school"], "distributor", "sponsor") { |c| contribs << c }

          fetch_howpublished(bibtex) { |c| contribs << c }

          contribs
        end

        def fetch_howpublished(bibtex, &_)
          return unless bibtex["howpublished"]

          /\\publisher\{(?<name>.+)\},\\url\{(?<url>.+)\}/ =~ bibtex.howpublished.to_s
          return unless name && url

          name.gsub!(/\{\\?([^\\]+)\}/, '\1')
          org = Organization.new(name: [TypedLocalizedString.new(content: name)], url: url)
          yield Contributor.new(
            organization: org,
            role: [Contributor::Role.new(type: "publisher")],
          )
        end

        # @param org [String, nil] organization name
        # @param type [String] role type
        # @param desc [String, nil] role description
        # @yield [Relaton::Bib::Contributor]
        def fetch_org(org, type, desc = nil, &_)
          return unless org

          role_obj = Contributor::Role.new(type: type)
          role_obj.description = [LocalizedMarkedUpString.new(content: desc)] if desc
          yield Contributor.new(organization: Organization.new(name: [TypedLocalizedString.new(content: org.to_s)]), role: [role_obj])
        end

        # @param bibtex [BibTeX::Entry]
        # @param role [String] contributor role
        # @yield [Relaton::Bib::Contributor]
        def fetch_person(bibtex, role, &_) # rubocop:disable Metrics/AbcSize
          bibtex[role]&.each do |name|
            parts = name.split ", "
            surname = LocalizedString.new(content: parts.first)
            fname = parts.size > 1 ? parts[1].split : []
            forename = fname.map { |fn| FullNameType::Forename.new(content: fn) }
            name = FullName.new(surname: surname, forename: forename)
            yield Contributor.new(
              person: Person.new(name: name),
              role: [Contributor::Role.new(type: role)],
            )
          end
        end

        # @param bibtex [BibTeX::Entry]
        # @return [Array<Relaton::Bib::Date>]
        def fetch_date(bibtex)
          date = []
          if bibtex["year"]
            on = ::Date.new(bibtex.year.to_i, bibtex["month_numeric"]&.to_i || 1).to_s
            date << Bib::Date.new(type: "published", at: on)
          end

          if bibtex["urldate"]
            date << Bib::Date.new(type: "accessed", at: ::Date.parse(bibtex.urldate.to_s).to_s)
          end

          date
        end

        # @param bibtex [BibTeX::Entry]
        # @return [Relaton::Bib::BiblioNoteCollection]
        def fetch_note(bibtex) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength
          bibtex.select do |k, _v|
            %i[annote howpublished comment note content].include? k
          end.reduce([]) do |mem, note|
            type = case note[0]
                  when :note then nil
                  when :content then "tableOfContents"
                  else note[0].to_s
                  end
            next mem if type == "howpublished" && note[1].to_s.match?(/^\\publisher\{.+\},\\url\{.+\}$/)

            mem << Note.new(type: type, content: note[1].to_s)
          end
        end

        # @param bibtex [BibTeX::Entry]
        # @return [Array<Relaton::Bib::Relation>]
        def fetch_relation(bibtex)
          return [] unless bibtex["booktitle"]

          ttl = Title.new(type: "main", content: bibtex.booktitle.to_s)
          [Relation.new(type: "partOf", bibitem: ItemData.new(title: [ttl]))]
        end

        # @param bibtex [BibTeX::Entry]
        # @return [Array<Relaton::Bib::Extent>]
        def fetch_extent(bibtex) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
          locs = bibtex.select do |k, _v|
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
            mem << Locality.new(type: type, reference_from: from, reference_to: to)
          end
          [Extent.new(locality: locs)]
        end

        # @param bibtex [BibTeX::Entry]
        # @return [Array<Relaton::Bib::Series>]
        def fetch_series(bibtex) # rubocop:disable Metrics/MethodLength
          series = []
          if bibtex["journal"]
            series << Series.new(
              type: "journal",
              title: Title.new(content: bibtex.journal.to_s),
              number: bibtex["number"]&.to_s,
            )
          end

          if bibtex["series"]
            title = Title.new content: bibtex.series.to_s
            series << Series.new(title: title)
          end
          series
        end

        # @param bibtex [BibTeX::Entry]
        # @return [Array<Relaton::Bib::Uri>]
        def fetch_link(bibtex) # rubocop:disable Metrics/AbcSize
          link = []
          link << Uri.new(type: "src", content: bibtex.url.to_s) if bibtex["url"]
          link << Uri.new(type: "doi", content: bibtex.doi.to_s) if bibtex["doi"]
          link << Uri.new(type: "file", content: bibtex.file2.to_s) if bibtex["file2"]
          link
        end

        # @param bibtex [BibTeX::Entry]
        # @return [Array<String>]
        def fetch_language(bibtex)
          return [] unless bibtex["language"]

          [Iso639[bibtex.language.to_s].alpha2]
        end

        # @param bibtex [BibTeX::Entry]
        # @return [Relaton::Bib::Classification, nil]
        def fetch_classification(bibtex)
          cls = []
          cls << Docidentifier.new(type: "type", content: bibtex["type"].to_s) if bibtex["type"]
          # cls << Docidentifier.new(type: "keyword", content: bibtex.keywords.to_s) if bibtex["keywords"]
          if bibtex["mendeley-tags"]
            cls << Docidentifier.new(type: "mendeley", content: bibtex["mendeley-tags"].to_s)
          end
          cls
        end

        # @param bibtex [BibTeX::Entry]
        # @return [Array<Relaton::Bib::Keyword>]
        def fetch_keyword(bibtex)
          bibtex["keywords"]&.split(/,\s?/)&.map do |kw|
            Keyword.new(taxon: [LocalizedString.new(content: kw)])
          end || []
        end

        # @param bibtex [BibTeX::Entry]
        # @return [Relaton::Bib::Edition, nil]
        def fetch_edition(bibtex)
          Edition.new(content: bibtex["edition"].to_s) if bibtex["edition"]
        end
      end
    end
  end
end
