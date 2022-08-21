require "nokogiri"

module RelatonBib
  class XMLParser
    class << self
      def from_xml(xml)
        doc = Nokogiri::XML(xml)
        doc.remove_namespaces!
        bibitem = doc.at "/bibitem|/bibdata"
        if bibitem
          bib_item item_data(bibitem)
        else
          warn "[relaton-bib] WARNING: can't find bibitem or bibdata element "\
               "in the XML"
        end
      end

      private

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize

      # @return [Hash]
      def item_data(bibitem) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        ext = bibitem.at "//ext"
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
          edition: fetch_edition(bibitem),
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
          size: fetch_size(bibitem),
          accesslocation: bibitem.xpath("./accesslocation").map(&:text),
          classification: fetch_classification(bibitem),
          keyword: bibitem.xpath("keyword").map(&:text),
          license: bibitem.xpath("license").map(&:text),
          validity: fetch_validity(bibitem),
          doctype: ext&.at("doctype")&.text,
          subdoctype: ext&.at("subdoctype")&.text,
          editorialgroup: fetch_editorialgroup(ext),
          ics: fetch_ics(ext),
          structuredidentifier: fetch_structuredidentifier(ext),
        }
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      def fetch_version(item)
        item.xpath("./version").map do |v|
          revision_date = v.at("revision-date")&.text
          draft = v.at("draft")&.text
          RelatonBib::BibliographicItem::Version.new revision_date, draft
        end
      end

      def fetch_edition(item)
        edt = item.at("./edition")
        return unless edt

        Edition.new content: edt.text, number: edt[:number]
      end

      def fetch_place(item)
        item.xpath("./place").map do |pl|
          if (city = pl.at("./city"))
            Place.new(city: city.text, region: create_region_country(pl),
                      country: create_region_country(pl, "country"))
          else
            Place.new(name: pl.text)
          end
        end
      end

      #
      # Create region or country from place element
      #
      # @param [Nokogiri::XML::Element] place place element
      # @param [String] node name of the node to parse
      #
      # @return [Array<RelatonBib::Place::RegionType>] <description>
      #
      def create_region_country(place, node = "region")
        place.xpath("./#{node}").map do |r|
          Place::RegionType.new(name: r.text, iso: r[:iso], recommended: r[:recommended])
        end
      end

      def fetch_note(item)
        bnotes = item.xpath("./note").map do |n|
          BiblioNote.new(
            content: n.text,
            type: n[:type],
            format: n[:format],
            language: n[:language],
            script: n[:script],
          )
        end
        BiblioNoteCollection.new bnotes
      end

      def fetch_language(item)
        item.xpath("./language").reduce([]) do |a, l|
          l.text.empty? ? a : a << l.text
        end
      end

      def fetch_script(item)
        item.xpath("./script").reduce([]) do |a, s|
          s.text.empty? ? a : a << s.text
        end
      end

      def fetch_series(item) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/AbcSize,Metrics/MethodLength,Metrics/PerceivedComplexity
        item.xpath("./series").reduce([]) do |mem, sr|
          abbr = sr.at "abbreviation"
          abbreviation = abbr &&
            LocalizedString.new(abbr.text, abbr[:language], abbr[:script])
          formattedref = fref(sr)
          title = ttitle(sr.at("title"))
          next mem unless formattedref || title

          mem << Series.new(
            type: sr[:type], formattedref: formattedref,
            title: title, place: sr.at("place")&.text,
            organization: sr.at("organization")&.text,
            abbreviation: abbreviation, from: sr.at("from")&.text,
            to: sr.at("to")&.text, number: sr.at("number")&.text,
            partnumber: sr.at("partnumber")&.text, run: sr.at("run")&.text,
          )
        end
      end

      def fetch_medium(item) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/AbcSize,Metrics/PerceivedComplexity
        medium = item.at("./medium")
        return unless medium

        Medium.new(
          content: medium.at("content")&.text, genre: medium.at("genre")&.text,
          form: medium.at("form")&.text, carrier: medium.at("carrier")&.text,
          size: medium.at("size")&.text, scale: medium.at("scale")&.text
        )
      end

      def fetch_extent(item)
        item.xpath("./extent").reduce([]) do |a, ex|
          a + localities(ex)
          # Locality.new(
          #   ex[:type], ex.at("referenceFrom")&.text, ex.at("referenceTo")&.text
          # )
        end
      end

      def fetch_size(item)
        size = item.xpath("./size/value").map do |sz|
          BibliographicSize::Value.new type: sz[:type], value: sz.text
        end
        BibliographicSize.new size if size.any?
      end

      def fetch_classification(item)
        item.xpath("classification").map do |cls|
          Classification.new type: cls[:type], value: cls.text
        end
      end

      def fetch_validity(item)
        vl = item.at("./validity")
        return unless vl

        begins = (b = vl.at("validityBegins")) &&
          Time.strptime(b.text, "%Y-%m-%d %H:%M")
        ends = (e = vl.at("validityEnds")) &&
          Time.strptime(e.text, "%Y-%m-%d %H:%M")
        revision = (r = vl.at("revision")) &&
          Time.strptime(r.text, "%Y-%m-%d %H:%M")
        Validity.new begins: begins, ends: ends, revision: revision
      end

      # @param item [Nokogiri::XML::Element]
      # @return [Array<RelatonBib::DocumentIdentifier>]
      def fetch_docid(item)
        item.xpath("./docidentifier").map do |id|
          did = id.to_h.transform_keys(&:to_sym)
          did[:id] = id.text
          did[:primary] = id[:primary] == "true" ? true : nil
          DocumentIdentifier.new(**did)
        end
      end

      # @param item [Nokogiri::XML::Element]
      # @return [RelatonBib::TypedTitleStringCollection]
      def fetch_titles(item)
        ttl = item.xpath("./title").map { |t| ttitle t }
        TypedTitleStringCollection.new ttl
      end

      # @param title [Nokogiri::XML::Element]
      # @return [RelatonBib::TypedTitleString]
      def ttitle(title)
        return unless title

        content = variants(title)
        content = title.text unless content.any?
        TypedTitleString.new(
          type: title[:type], content: content, language: title[:language],
          script: title[:script], format: title[:format]
        )
      end

      # @param title [Nokogiri::XML::Element]
      # @return [Array<RelatonBib::LocalizedString>]
      def variants(elm)
        elm.xpath("variant").map do |v|
          LocalizedString.new v.text, v[:language], v[:script]
        end
      end

      def fetch_status(item)
        status = item.at("./status")
        return unless status

        stg = status.at "stage"
        DocumentStatus.new(
          stage: stg ? stage(stg) : status.text,
          substage: stage(status.at("substage")),
          iteration: status.at("iteration")&.text,
        )
      end

      # @param node [Nokogiri::XML::Elemen]
      # @return [RelatonBib::DocumentStatus::Stage]
      def stage(elm)
        return unless elm

        DocumentStatus::Stage.new(value: elm.text,
                                  abbreviation: elm[:abbreviation])
      end

      # @param node [Nokogiri::XML::Elemen]
      # @return [Array<RelatonBib::BibliographicDate>]
      def fetch_dates(item) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
        item.xpath("./date").each_with_object([]) do |d, a|
          type = d[:type].to_s.empty? ? "published" : d[:type]
          if (on = d.at("on"))
            a << RelatonBib::BibliographicDate.new(type: type, on: on.text,
                                                   to: d.at("to")&.text)
          elsif (from = d.at("from"))
            a << RelatonBib::BibliographicDate.new(type: type, from: from.text,
                                                   to: d.at("to")&.text)
          end
        end
      end

      def get_org(org) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        names = org.xpath("name").map do |n|
          { content: n.text, language: n[:language], script: n[:script] }
        end
        identifier = org.xpath("./identifier").map do |i|
          OrgIdentifier.new(i[:type], i.text)
        end
        subdiv = org.xpath("subdivision").map &:text
        contact = parse_contact org
        Organization.new(
          name: names, abbreviation: org.at("abbreviation")&.text,
          subdivision: subdiv, # url: org.at("uri")&.text,
          identifier: identifier, contact: contact
        )
      end

      def get_person(person) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
        affiliations = person.xpath("./affiliation").map do |a|
          org = a.at "./organization"
          desc = a.xpath("./description").map do |e|
            FormattedString.new(content: e.text, language: e[:language],
                                script: e[:script], format: e[:format])
          end
          Affiliation.new organization: get_org(org), description: desc
        end

        contact = parse_contact person
        identifier = person.xpath("./identifier").map do |pi|
          PersonIdentifier.new pi[:type], pi.text
        end

        cn = person.at "./name/completename"
        cname = cn && LocalizedString.new(cn.text, cn[:language], cn[:script])
        sn = person.at "./name/surname"
        sname = sn && LocalizedString.new(sn.text, sn[:language], sn[:script])

        name = FullName.new(
          completename: cname, surname: sname,
          initials: parse_initials(person),
          forename: parse_forename(person),
          addition: name_part(person, "addition"),
          prefix: name_part(person, "prefix")
        )

        Person.new(
          name: name,
          affiliation: affiliations,
          contact: contact,
          identifier: identifier,
        )
      end

      def parse_contact(contrib) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/MethodLength,Metrics/AbcSize
        contrib.xpath("./address|./phone|./email|./uri").map do |c|
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
      end

      def parse_initials(person)
        inits = person.at "./name/formatted-initials"
        return unless inits

        LocalizedString.new(inits.text, inits[:language], inits[:script])
      end

      def parse_forename(person)
        person.xpath("./name/forename").map do |np|
          args = np.attributes.each_with_object({}) { |(k, v), h| h[k.to_sym] = v.to_s }
          args[:content] = np.text
          Forename.new(**args)
        end
      end

      def name_part(person, part)
        person.xpath("./name/#{part}").map do |np|
          LocalizedString.new np.text, np[:language], np[:script]
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
            { type: r[:type],
              description: r.xpath("./description").map(&:text) }
          end
          ContributionInfo.new entity: entity, role: role
        end
      end

      # @param item [Nokogiri::XML::Element]
      # @return [Array<RelatonBib::FormattedString>]
      def fetch_abstract(item)
        item.xpath("./abstract").map do |a|
          c = a.inner_html(encoding: "utf-8").strip
          FormattedString.new(content: c, language: a[:language],
                              script: a[:script], format: a[:format])
        end
      end

      # @param item [Nokogiri::XML::Element]
      # @return [Array<RelatonBib::CopyrightAssociation>]
      def fetch_copyright(item) # rubocop:disable Metrics/AbcSize
        item.xpath("./copyright").map do |cp|
          owner = cp.xpath("owner").map do |o|
            ContributionInfo.new entity: get_org(o.at("organization"))
          end
          from = cp.at("from")&.text
          to   = cp.at("to")&.text
          scope = cp.at("scope")&.text
          CopyrightAssociation.new(owner: owner, from: from, to: to,
                                   scope: scope)
        end
      end

      # @param item [Nokogiri::XML::Element]
      # @return [Arra<RelatonBib::TypedUri>]
      def fetch_link(item)
        item.xpath("./uri").map do |l|
          TypedUri.new type: l[:type], content: l.text
        end
      end

      # @param item [Nokogiri::XML::Element]
      # @param klass [RelatonBib::DocumentRelation.class,
      #   RelatonNist::DocumentRelation.class]
      # @return [Array<RelatonBib::DocumentRelation>]
      def fetch_relations(item, klass = DocumentRelation)
        item.xpath("./relation").map do |rel|
          klass.new(
            type: rel[:type]&.empty? ? nil : rel[:type],
            description: relation_description(rel),
            bibitem: bib_item(item_data(rel.at("./bibitem"))),
            locality: localities(rel),
            source_locality: source_localities(rel),
          )
        end
      end

      # @param rel [Nokogiri::XML::Element]
      # @return [RelatonBib::FormattedString, NilClass]
      def relation_description(rel)
        d = rel.at "./description"
        return unless d

        FormattedString.new(content: d.text, language: d[:language],
                            script: d[:script], format: d[:format])
      end

      # @param item_hash [Hash]
      # @return [RelatonBib::BibliographicItem]
      def bib_item(item_hash)
        BibliographicItem.new(**item_hash)
      end

      # @param rel [Nokogiri::XML::Element]
      # @return [Array<RelatonBib::Locality, RelatonBib::LocalityStack>]
      def localities(rel)
        rel.xpath("./locality|./localityStack").map do |lc|
          if lc.name == "locality"
            locality lc
          else
            LocalityStack.new(lc.xpath("./locality").map { |l| locality l })
          end
        end
      end

      #
      # Create Locality object from Nokogiri::XML::Element
      #
      # @param loc [Nokogiri::XML::Element]
      # @param klass [RelatonBib::Locality.class, RelatonBib::LocalityStack.class]
      #
      # @return [RelatonBib::Locality]
      def locality(loc, klass = Locality)
        klass.new(
          loc[:type],
          loc.at("./referenceFrom")&.text,
          loc.at("./referenceTo")&.text,
        )
      end

      # @param rel [Nokogiri::XML::Element]
      # @return [Array<RelatonBib::SourceLocality,
      #   RelatonBib::SourceLocalityStack>]
      def source_localities(rel)
        rel.xpath("./sourceLocality|./sourceLocalityStack").map do |lc|
          if lc[:type]
            SourceLocalityStack.new [locality(lc, SourceLocality)]
          else
            sls = lc.xpath("./sourceLocality").map do |l|
              locality l, SourceLocality
            end
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
          content: ident.children.to_s, format: ident[:format],
          language: ident[:language], script: ident[:script]
        )
      end

      # @param ext [Nokogiri::XML::Element]
      # @return [RelatonBib::EditorialGroup, nil]
      def fetch_editorialgroup(ext)
        return unless ext && (eg = ext.at "editorialgroup")

        eg = eg.xpath("technical-committee").map do |tc|
          wg = WorkGroup.new(
            name: tc.text, number: tc[:number]&.to_i, type: tc[:type],
            identifier: tc[:identifier], prefix: tc[:prefix]
          )
          TechnicalCommittee.new wg
        end
        EditorialGroup.new eg if eg.any?
      end

      def fetch_ics(ext)
        return [] unless ext

        ext.xpath("ics").map do |ics|
          ICS.new code: ics.at("code")&.text, text: ics.at("text")&.text
        end
      end

      # @param ext [Nokogiri::XML::Element]
      # @return [RelatonBib::StructuredIdentifierCollection]
      def fetch_structuredidentifier(ext) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
        return unless ext

        sids = ext.xpath("structuredidentifier").map do |si|
          StructuredIdentifier.new(
            type: si[:type],
            agency: si.xpath("agency").map(&:text),
            class: si.at("class")&.text,
            docnumber: si.at("docnumber")&.text,
            partnumber: si.at("partnumber")&.text,
            edition: si.at("edition")&.text,
            version: si.at("version")&.text,
            supplementtype: si.at("supplementtype")&.text,
            supplementnumber: si.at("supplementnumber")&.text,
            language: si.at("language")&.text,
            year: si.at("year")&.text,
          )
        end
        StructuredIdentifierCollection.new sids
      end
    end
  end
end
