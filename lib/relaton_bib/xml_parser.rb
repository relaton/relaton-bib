require "nokogiri"

module RelatonBib
  class XMLParser
    class << self
      def from_xml(xml)
        doc = Nokogiri::XML(xml)
        bibitem = doc.at "/bibitem"
        BibliographicItem.new(item_data(bibitem))
      end

      private

      def item_data(bibitem)
        {
          id: bibitem[:id],
          type: bibitem[:type],
          fetched: bibitem.at("./fetched")&.text,
          titles: fetch_titles(bibitem),
          formattedref: fref(bibitem),
          link: fetch_link(bibitem),
          docid: fetch_docid(bibitem),
          docnumber: bibitem.at("./docnumber")&.text,
          dates: fetch_dates(bibitem),
          contributors: fetch_contributors(bibitem),
          edition: bibitem.at("./edition")&.text,
          version: fetch_version(bibitem),
          biblionote: fetch_note(bibitem),
          language: bibitem.xpath("./language").map(&:text),
          script: bibitem.xpath("./script").map(&:text),
          abstract: fetch_abstract(bibitem),
          docstatus: fetch_status(bibitem),
          copyright: fetch_copyright(bibitem),
          relations: fetch_relations(bibitem),
          series: fetch_series(bibitem),
          medium: fetch_medium(bibitem),
          place: bibitem.xpath("./place").map(&:text),
          extent: fetch_extent(bibitem),
          accesslocation: bibitem.xpath("./accesslocation").map(&:text),
          classification: fetch_classification(bibitem),
          validity: fetch_validity(bibitem),
        }
      end

      def fetch_version(item)
        version = item.at "./version"
        return unless version

        revision_date = version.at("revision_date").text
        draft = version.xpath("draft").map &:text
        RelatonBib::BibliographicItem::Version.new revision_date, draft
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

      def fetch_series(item)
        item.xpath("./series").map do |sr|
          abbr = sr.at "abbreviation"
          abbreviation = abbr ? LocalizedString.new(abbr.text, abbr[:language], abbr[:script]) : nil
          Series.new(type: sr[:type], formattedref: fref(sr),
            title: ttitle(sr.at "title"), place: sr.at("place")&.text,
            organization: sr.at("organization")&.text, abbreviation: abbreviation,
            from: sr.at("from")&.text, to: sr.at("to")&.text, number: sr.at("number")&.text,
            partnumber: sr.at("partnumber")&.text
          )
        end
      end

      def fetch_medium(item)
        medium = item.at("./medium")
        return unless medium

        Medium.new(
          form: medium.at("form")&.text, size: medium.at("size")&.text,
          scale: medium.at("scale")&.text
        )
      end

      def fetch_extent(item)
        item.xpath("./locality").map do |ex|
          BibItemLocality.new(
            ex[:type], ex.at("referenceFrom")&.text, ex.at("referenceTo")&.text
          )
        end
      end

      def fetch_classification(item)
        cls = item.at "classification"
        return unless cls

        Classification.new type: cls[:type], value: cls.text
      end

      def fetch_validity(item)
        vl = item.at("./validity")
        return unless vl

        begins = (b = vl.at("validityBegins")) ? Time.strptime(b.text, "%Y-%m-%d %H:%M") : nil
        ends = (e = vl.at("validityEnds")) ? Time.strptime(e.text, "%Y-%m-%d %H:%M") : nil
        revision = (r = vl.at("validityRevision")) ? Time.strptime(r.text, "%Y-%m-%d %H:%M") : nil
        Validity.new begins: begins, ends: ends, revision: revision
      end

      # def get_id(did)
      #   did.text.match(/^(?<project>.*?\d+)(?<hyphen>-)?(?(<hyphen>)(?<part>\d*))/)
      # end

      def fetch_docid(item)
        ret = []
        item.xpath("./docidentifier").each do |did|
          #did = doc.at('/bibitem/docidentifier')
          # type = did.at("./@type")
          # if did.text == "IEV" then
          #   ret << DocumentIdentifier.new(id: "IEV",  nil)
          # else
            # id = get_id did
          ret << DocumentIdentifier.new(id: did.text, type: did[:type])
          # end
        end
        ret
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

        DocumentStatus.new(
          stage: status.at("stage").text,
          substage: status.at("substage")&.text,
          iteration: status.at("iteration")&.text,
        )
      end

      def fetch_dates(item)
        item.xpath('./date').map do |d|
          RelatonBib::BibliographicDate.new(
            type: d[:type], on: d.at('on')&.text, from: d.at('from')&.text,
            to: d.at('to')&.text
          )
        end
      end

      def get_org(org)
        names = org.xpath("name").map do |n|
          { content: n.text, language: n[:language], script: n[:script] }
        end
        identifiers = org.xpath("./identifier").map do |i|
          OrgIdentifier.new(i[:type], i.text)
        end
        Organization.new(name: names,
                         abbreviation: org.at("abbreviation")&.text,
                         subdivision: org.at("subdivision")&.text,
                         url: org.at("uri")&.text,
                         identifiers: identifiers)
      end

      def get_person(person)
        affilations = person.xpath("./affiliation").map do |a|
          org = a.at "./organization"
          Affilation.new get_org(org)
        end

        contacts = person.xpath("./address | ./phone | ./email | ./uri").map do |contact|
          if contact.name == "address"
            streets = contact.xpath("./street").map(&:text)
            Address.new(
              street: streets,
              city: contact.at("./city").text,
              state: contact.at("./state").text,
              country: contact.at("./country").text,
              postcode: contact.at("./postcode").text,
            )
          else
            Contact.new(type: contact.name, value: contact.text)
          end
        end

        identifiers = person.xpath("./identifier").map do |pi|
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
          initials: name_part(person, "initial"), forenames: name_part(person, "forename"),
          additions: name_part(person, "addition"), prefix: name_part(person, "prefix")
        )

        Person.new(
          name: name,
          affiliation: affilations,
          contacts: contacts,
          identifiers: identifiers,
        )
      end

      def name_part(person, part)
        person.xpath("./name/#{part}").map do |np|
          LocalizedString.new np.text, np[:language]
        end
      end

      def fetch_contributors(item)
        item.xpath("./contributor").map do |c|
          entity = if (org = c.at "./organization") then get_org(org)
                   elsif (person = c.at "./person") then get_person(person)
                   end
          role_descr = c.xpath("./role/description").map &:text
          ContributionInfo.new entity: entity, role: [[c.at("role")[:type], role_descr]]
        end
      end

      def fetch_abstract(item)
        item.xpath("./abstract").map do |a|
          FormattedString.new(
            content: a.text, language: a[:language], script: a[:script], format: a[:format]
          )
        end
      end

      def fetch_copyright(item)
        cp     = item.at("./copyright") || return
        org    = cp&.at("owner/organization")
        name   = org&.at("name").text
        abbr   = org&.at("abbreviation")&.text
        url    = org&.at("uri")&.text
        entity = Organization.new(name: name, abbreviation: abbr, url: url)
        from   = cp.at("from")&.text
        to     = cp.at("to")&.text
        owner  = ContributionInfo.new entity: entity
        CopyrightAssociation.new(owner: owner, from: from, to: to)
      end

      def fetch_link(item)
        item.xpath("./uri").map do |l|
          TypedUri.new type: l[:type], content: l.text
        end
      end

      def fetch_relations(item)
        item.xpath("./relation").map do |rel|
          localities = rel.xpath("./locality").map do |l|
            ref_to = (rt = l.at("./referenceTo")) ? LocalizedString.new(rt.text) : nil
            BibItemLocality.new(
              l[:type],
              LocalizedString.new(l.at("./referenceFrom").text),
              ref_to,
            )
          end
          DocumentRelation.new(
            type: rel[:type],
            bibitem: BibliographicItem.new(item_data(rel.at("./bibitem"))),
            bib_locality: localities,
          )
        end
      end

      def fref(item)
        ident = item&.at("./formattedref | ./docidentifier")
        return unless ident

        FormattedRef.new(
          content: ident&.text, format: ident[:format],
          language: ident[:language], script: ident[:script]
        )
      end
    end
  end
end
