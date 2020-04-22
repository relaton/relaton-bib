require "nokogiri"

module RelatonBib
  class XMLParser
    class << self
      def from_xml(xml)
        doc = Nokogiri::XML(xml)
        doc.remove_namespaces!
        bibitem = doc.at "/bibitem|/bibdata"
        if bibitem
          BibliographicItem.new(item_data(bibitem))
        else
          warn "[relato-bib] WARNING: can't find bibitem or bibdata element in the XML"
        end
      end

      private

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize

      # @return [Hash]
      def item_data(bibitem)
        {
          id: bibitem[:id]&.empty? ? nil : bibitem[:id],
          type: bibitem[:type]&.empty? ? nil : bibitem[:type],
          fetched: bibitem.at("./fetched")&.text,
          title: fetch_titles(bibitem),
          formattedref: fref(bibitem),
          link: fetch_link(bibitem),
          docid: fetch_docid(bibitem),
          docnumber: bibitem.at("./docnumber")&.text,
          date: fetch_dates(bibitem),
          contributor: fetch_contributors(bibitem),
          edition: bibitem.at("./edition")&.text,
          version: fetch_version(bibitem),
          biblionote: fetch_note(bibitem),
          language: fetch_language(bibitem),
          script: fetch_script(bibitem),
          abstract: fetch_abstract(bibitem),
          docstatus: fetch_status(bibitem),
          copyright: fetch_copyright(bibitem),
          relation: fetch_relations(bibitem),
          series: fetch_series(bibitem),
          medium: fetch_medium(bibitem),
          place: fetch_place(bibitem),
          extent: fetch_extent(bibitem),
          accesslocation: bibitem.xpath("./accesslocation").map(&:text),
          classification: fetch_classification(bibitem),
          keyword: bibitem.xpath("keyword").map(&:text),
          license: bibitem.xpath("license").map(&:text),
          validity: fetch_validity(bibitem),
        }
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      def fetch_version(item)
        version = item.at "./version"
        return unless version

        revision_date = version.at("revision-date")&.text
        draft = version.xpath("draft").map &:text
        RelatonBib::BibliographicItem::Version.new revision_date, draft
      end

      def fetch_place(item)
        item.xpath("./place").map do |pl|
          Place.new(name: pl.text, uri: pl[:uri], region: pl[:region])
        end
      end

      def fetch_note(item)
        item.xpath("./note").map do |n|
          BiblioNote.new(
            content: n.text,
            type: n[:type],
            format: n[:format],
            language: n[:language],
            script: n[:script],
          )
        end
      end

      def fetch_language(item)
        item.xpath("./language").reduce([]) { |a, l| l.text.empty? ? a : a << l.text }
      end

      def fetch_script(item)
        item.xpath("./script").reduce([]) { |a, s| s.text.empty? ? a : a << s.text }
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength

      def fetch_series(item)
        item.xpath("./series").map do |sr|
          abbr = sr.at "abbreviation"
          abbreviation = abbr ? LocalizedString.new(abbr.text, abbr[:language], abbr[:script]) : nil
          Series.new(
            type: sr[:type], formattedref: fref(sr),
            title: ttitle(sr.at("title")), place: sr.at("place")&.text,
            organization: sr.at("organization")&.text,
            abbreviation: abbreviation, from: sr.at("from")&.text,
            to: sr.at("to")&.text, number: sr.at("number")&.text,
            partnumber: sr.at("partnumber")&.text
          )
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      def fetch_medium(item)
        medium = item.at("./medium")
        return unless medium

        Medium.new(
          form: medium.at("form")&.text, size: medium.at("size")&.text,
          scale: medium.at("scale")&.text
        )
      end

      def fetch_extent(item)
        item.xpath("./extent").map do |ex|
          BibItemLocality.new(
            ex[:type], ex.at("referenceFrom")&.text, ex.at("referenceTo")&.text
          )
        end
      end

      def fetch_classification(item)
        item.xpath("classification").map do |cls|
          Classification.new type: cls[:type], value: cls.text
        end
      end

      def fetch_validity(item)
        vl = item.at("./validity")
        return unless vl

        begins = (b = vl.at("validityBegins")) ? Time.strptime(b.text, "%Y-%m-%d %H:%M") : nil
        ends = (e = vl.at("validityEnds")) ? Time.strptime(e.text, "%Y-%m-%d %H:%M") : nil
        revision = (r = vl.at("revision")) ? Time.strptime(r.text, "%Y-%m-%d %H:%M") : nil
        Validity.new begins: begins, ends: ends, revision: revision
      end

      # @param item [Nokogiri::XML::Element]
      # @return [Array<RelatonBib::DocumentIdentifier>]
      def fetch_docid(item)
        item.xpath("./docidentifier").map do |did|
          DocumentIdentifier.new(id: did.text, type: did[:type])
        end
      end

      def fetch_titles(item)
        item.xpath("./title").map { |t| ttitle t }
      end

      def ttitle(title)
        return unless title

        TypedTitleString.new(
          type: title[:type], content: title.text, language: title[:language],
          script: title[:script], format: title[:format]
        )
      end

      def fetch_status(item)
        status = item.at("./status")
        return unless status

        stage = status.at "stage"
        DocumentStatus.new(
          stage: stage ? stage.text : status.text,
          substage: status.at("substage")&.text,
          iteration: status.at("iteration")&.text,
        )
      end

      def fetch_dates(item)
        item.xpath("./date").reduce([]) do |a, d|
          type = d[:type].to_s.empty? ? "published" : d[:type]
          if (on = d.at("on"))
            a << RelatonBib::BibliographicDate.new(type: type, on: on.text, to: d.at("to")&.text)
          elsif (from = d.at("from"))
            a << RelatonBib::BibliographicDate.new(type: type, from: from.text, to: d.at("to")&.text)
          end
        end
      end

      def get_org(org)
        names = org.xpath("name").map do |n|
          { content: n.text, language: n[:language], script: n[:script] }
        end
        identifier = org.xpath("./identifier").map do |i|
          OrgIdentifier.new(i[:type], i.text)
        end
        Organization.new(name: names,
                         abbreviation: org.at("abbreviation")&.text,
                         subdivision: org.at("subdivision")&.text,
                         url: org.at("uri")&.text,
                         identifier: identifier)
      end

      def get_person(person)
        affiliations = person.xpath("./affiliation").map do |a|
          org = a.at "./organization"
          desc = a.xpath("./description").map do |e|
            FormattedString.new(content: e.text, language: e[:language],
                                script: e[:script], format: e[:format])
          end
          Affiliation.new organization: get_org(org), description: desc
        end

        contact = person.xpath("./address | ./phone | ./email | ./uri").map do |c|
          if c.name == "address"
            streets = c.xpath("./street").map(&:text)
            Address.new(
              street: streets,
              city: c.at("./city")&.text,
              state: c.at("./state")&.text,
              country: c.at("./country")&.text,
              postcode: c.at("./postcode")&.text,
            )
          else
            Contact.new(type: c.name, value: c.text)
          end
        end

        identifier = person.xpath("./identifier").map do |pi|
          PersonIdentifier.new pi[:type], pi.text
        end

        cn = person.at "./name/completename"
        cname = if cn
                  LocalizedString.new(cn.text, cn[:language], cn[:script])
                else
                  nil
                end

        sn = person.at "./name/surname"
        sname = sn ? LocalizedString.new(sn.text, sn[:language], sn[:script]) : nil

        name = FullName.new(
          completename: cname, surname: sname,
          initial: name_part(person, "initial"), forename: name_part(person, "forename"),
          addition: name_part(person, "addition"), prefix: name_part(person, "prefix")
        )

        Person.new(
          name: name,
          affiliation: affiliations,
          contact: contact,
          identifier: identifier,
        )
      end

      def name_part(person, part)
        person.xpath("./name/#{part}").map do |np|
          LocalizedString.new np.text, np[:language]
        end
      end

      # @param item [Nokogiri::XML::Element]
      # @return [Array<RelatonBib::ContributionInfo>]
      def fetch_contributors(item)
        item.xpath("./contributor").map do |c|
          entity = if (org = c.at "./organization") then get_org(org)
                   elsif (person = c.at "./person") then get_person(person)
                   end
          role = c.xpath("./role").map do |r|
            { type: r[:type], description: r.xpath("./description").map(&:text) }
          end
          ContributionInfo.new entity: entity, role: role
        end
      end

      # @param item [Nokogiri::XML::Element]
      # @return [Array<RelatonBib::FormattedString>]
      def fetch_abstract(item)
        item.xpath("./abstract").map do |a|
          FormattedString.new(
            content: a.text, language: a[:language], script: a[:script], format: a[:format]
          )
        end
      end

      # @param item [Nokogiri::XML::Element]
      # @return [RelatonBib::CopyrightAssociation]
      def fetch_copyright(item)
        cp     = item.at("./copyright") || return
        org    = cp&.at("owner/organization")
        name   = org&.at("name")&.text
        abbr   = org&.at("abbreviation")&.text
        url    = org&.at("uri")&.text
        entity = Organization.new(name: name, abbreviation: abbr, url: url)
        from   = cp.at("from")&.text
        to     = cp.at("to")&.text
        owner  = ContributionInfo.new entity: entity
        CopyrightAssociation.new(owner: owner, from: from, to: to)
      end

      # @param item [Nokogiri::XML::Element]
      # @return [Arra<RelatonBib::TypedUri>]
      def fetch_link(item)
        item.xpath("./uri").map do |l|
          TypedUri.new type: l[:type], content: l.text
        end
      end

      # @param item [Nokogiri::XML::Element]
      # @return [Array<RelatonBib::DocumentRelation>]
      def fetch_relations(item)
        item.xpath("./relation").map do |rel|
          DocumentRelation.new(
            type: rel[:type]&.empty? ? nil : rel[:type],
            bibitem: BibliographicItem.new(item_data(rel.at("./bibitem"))),
            locality: localities(rel),
            source_locality: source_localities(rel),
          )
        end
      end

      # @param rel [Nokogiri::XML::Element]
      # @return [Array<RelatonBib::Locality, RelatonBib::LocalityStack>]
      def localities(rel)
        rel.xpath("./locality|./localityStack").map do |lc|
          if lc[:type]
            LocalityStack.new [locality(lc)]
          else
            LocalityStack.new lc.xpath("./locality").map { |l| locality l }
          end
        end
      end

      # @param loc [Nokogiri::XML::Element]
      # @return [RelatonBib::Locality]
      def locality(loc, klass = Locality)
        ref_to = (rt = loc.at("./referenceTo")) ? LocalizedString.new(rt.text) : nil
        klass.new(
          loc[:type],
          LocalizedString.new(loc.at("./referenceFrom").text),
          ref_to,
        )
      end

      # @param rel [Nokogiri::XML::Element]
      # @return [Array<RelatonBib::SourceLocality, RelatonBib::SourceLocalityStack>]
      def source_localities(rel)
        rel.xpath("./sourceLocality|./sourceLocalityStack").map do |lc|
          if lc[:type]
            SourceLocalityStack.new [locality(lc, SourceLocality)]
          else
            sls = lc.xpath("./sourceLocality").map { |l| locality l, SourceLocality }
            SourceLocalityStack.new sls
          end
        end
      end

      # @param item [Nokogiri::XML::Element]
      # @return [RelatonBib::FormattedRef, NilClass]
      def fref(item)
        ident = item&.at("./formattedref")
        return unless ident

        FormattedRef.new(
          content: ident&.text, format: ident[:format],
          language: ident[:language], script: ident[:script]
        )
      end
    end
  end
end
