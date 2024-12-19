require "nokogiri"

module RelatonBib
  class XMLParser
    class << self
      #
      # Parse XML bibdata
      #
      # @param [String] xml XML string
      #
      # @return [RelatonBib::BibliographicItem, nil] bibliographic item
      #
      def from_xml(xml)
        doc = Nokogiri::XML(xml)
        doc.remove_namespaces!
        bibitem = doc.at "/bibitem|/bibdata"
        if bibitem
          bib_item item_data(bibitem)
        else
          Util.warn "Can't find bibitem or bibdata element in the XML"
          nil
        end
      end

      private

      #
      # Parse bibitem data
      #
      # @param bibitem [Nokogiri::XML::Element] bibitem element
      #
      # @return [Hash] bibitem data
      #
      def item_data(bibitem) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize, Metrics/MethodLength
        ext = bibitem.at "//ext"
        {
          id: bibitem[:id].nil? || bibitem[:id].empty? ? nil : bibitem[:id],
          type: bibitem[:type].nil? || bibitem[:type].empty? ? nil : bibitem[:type],
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
          doctype: fetch_doctype(ext),
          subdoctype: ext&.at("subdoctype")&.text,
          editorialgroup: fetch_editorialgroup(ext),
          ics: fetch_ics(ext),
          structuredidentifier: fetch_structuredidentifier(ext),
        }
      end

      #
      # Fetch version.
      #
      # @param [Nokogiri::XML::Elemetn] item bibitem element
      #
      # @return [Array<RelatonBib::BibliographicItem::Version>] versions
      #
      def fetch_version(item)
        item.xpath("./version").map do |v|
          revision_date = v.at("revision-date")&.text
          draft = v.at("draft")&.text
          RelatonBib::BibliographicItem::Version.new revision_date, draft
        end
      end

      #
      # Fetch edition
      #
      # @param [Nokogiri::XML::Elemetn] item bibitem element
      #
      # @return [RelatonBib::Edition, nil] edition
      #
      def fetch_edition(item)
        edt = item.at("./edition")
        return unless edt

        Edition.new content: edt.text, number: edt[:number]
      end

      #
      # Fetch place.
      #
      # @param [Nokogiri::XML::Element] item bibitem element
      #
      # @return [Array<RelatonBib::Place>] array of places
      #
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

      #
      # Fetch language
      #
      # @param [Nokogiri::XML::Element] item bibitem element
      #
      # @return [Array<String>] language en, fr, etc.
      #
      def fetch_language(item)
        item.xpath("./language").reduce([]) do |a, l|
          l.text.empty? ? a : a << l.text
        end
      end

      #
      # Fetch script
      #
      # @param [Nokogiri::XML::Element] item XML element
      #
      # @return [Array<String>] scripts Latn, Cyr, etc.
      #
      def fetch_script(item)
        item.xpath("./script").reduce([]) do |a, s|
          s.text.empty? ? a : a << s.text
        end
      end

      #
      # Fetch series
      #
      # @param [Nokogiri::XML::Element] item bibitem element
      #
      # @return [Array<RelatonBib::Series>] series
      #
      def fetch_series(item) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/AbcSize,Metrics/MethodLength,Metrics/PerceivedComplexity
        item.xpath("./series").reduce([]) do |mem, sr|
          formattedref = fref(sr)
          title = ttitle(sr.at("title"))
          next mem unless formattedref || title

          abbreviation = localized_string sr.at("abbreviation")
          mem << Series.new(
            type: sr[:type], formattedref: formattedref,
            title: title, place: sr.at("place")&.text,
            organization: sr.at("organization")&.text,
            abbreviation: abbreviation, from: sr.at("from")&.text,
            to: sr.at("to")&.text, number: sr.at("number")&.text,
            partnumber: sr.at("partnumber")&.text, run: sr.at("run")&.text
          )
        end
      end

      #
      # Fetch medium
      #
      # @param [Nokogiri::XML::Element] item item element
      #
      # @return [RelatonBib::Medium, nil] medium
      #
      def fetch_medium(item) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/AbcSize,Metrics/PerceivedComplexity
        medium = item.at("./medium")
        return unless medium

        Medium.new(
          content: medium.at("content")&.text, genre: medium.at("genre")&.text,
          form: medium.at("form")&.text, carrier: medium.at("carrier")&.text,
          size: medium.at("size")&.text, scale: medium.at("scale")&.text
        )
      end

      #
      # Fetch extent
      #
      # @param [Nokogiri::XML::Element] item item element
      #
      # @return [Array<RelatonBib::Extent>] extent
      #
      def fetch_extent(item)
        item.xpath("./extent").map do |ex|
          RelatonBib::Extent.new localities(ex)
        end
      end

      #
      # Fetch size
      #
      # @param [Nokogiri::XML::Element] item item element
      #
      # @return [RelatonBib::BibliographicSize, nil] size
      #
      def fetch_size(item)
        size = item.xpath("./size/value").map do |sz|
          BibliographicSize::Value.new type: sz[:type], value: sz.text
        end
        BibliographicSize.new size if size.any?
      end

      #
      # Fetch classification
      #
      # @param [Nokogiri::XML::Element] item bibitem element
      #
      # @return [Array<RelatonBib::Classification>] classifications
      #
      def fetch_classification(item)
        item.xpath("classification").map do |cls|
          Classification.new type: cls[:type], value: cls.text
        end
      end

      #
      # Parse validity
      #
      # @param [Nokogiri::XML::Element] item bibitem element
      #
      # @return [RelatonBib::Validity, nil] validity
      #
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

      def fetch_doctype(ext)
        dt = ext&.at("doctype")
        return unless dt

        create_doctype dt
      end

      def create_doctype(type)
        DocumentType.new type: type.text, abbreviation: type[:abbreviation]
      end

      # @param item [Nokogiri::XML::Element]
      # @return [Array<RelatonBib::DocumentIdentifier>]
      def fetch_docid(item)
        item.xpath("./docidentifier").map do |id|
          args = id.to_h.transform_keys(&:to_sym)
          args[:id] = id.children.map { |n| n.text? ? n.content : n.to_xml }.join
          args[:primary] = id[:primary] == "true" ? true : nil
          create_docid(**args)
        end
      end

      def create_docid(**args)
        DocumentIdentifier.new(**args)
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
        content = title.children.map { |n| n.text? ? n.content : n.to_xml }.join unless content.any?
        TypedTitleString.new(
          type: title[:type], content: content, language: title[:language],
          script: title[:script], format: title[:format]
        )
      end

      # @param title [Nokogiri::XML::Element]
      # @return [Array<RelatonBib::LocalizedString>]
      def variants(elm)
        elm.xpath("variant").map { |v| localized_string v }
      end

      #
      # Parse status
      #
      # @param [Nokogiri::XML::Element] item XML element
      #
      # @return [RelatonBib::DocumentStatus, nil] status
      #
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

      #
      # Parse organization
      #
      # @param [Nokogiri::XML::Element] org XML element
      #
      # @return [RelatonBib::Organization, nil] organization
      #
      def get_org(org) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        return unless org

        names = org.xpath("name").map do |n|
          { content: n.text, language: n[:language], script: n[:script] }
        end
        identifier = org.xpath("./identifier").map do |i|
          OrgIdentifier.new(i[:type], i.text)
        end
        subdiv = org.xpath("subdivision").map &:text
        contact = parse_contact org
        logo = fetch_image org.at("./logo/image")
        Organization.new(
          name: names, abbreviation: org.at("abbreviation")&.text,
          subdivision: subdiv, # url: org.at("uri")&.text,
          identifier: identifier, contact: contact, logo: logo
        )
      end

      def fetch_image(elm)
        return unless elm

        Image.new(**elm.to_h.transform_keys(&:to_sym))
      end

      #
      # Parse person from XML
      #
      # @param [Nokogiri::XML::Element] person XML element
      #
      # @return [RelatonBib::Person, nil] person
      #
      def get_person(person) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        return unless person

        affiliations = person.xpath("./affiliation").map { |a| fetch_affiliation a }

        contact = parse_contact person
        identifier = person.xpath("./identifier").map do |pi|
          PersonIdentifier.new pi[:type], pi.text
        end

        Person.new(
          name: full_name(person.at("./name")),
          credential: person.xpath("./credential").map(&:text),
          affiliation: affiliations,
          contact: contact,
          identifier: identifier,
        )
      end

      def full_name(name)
        cname = localized_string name.at("./completename")
        sname = localized_string name.at("./surname")
        abbreviation = localized_string name.at("./abbreviation")

        FullName.new(
          completename: cname, surname: sname, abbreviation: abbreviation,
          initials: parse_initials(name), forename: parse_forename(name),
          addition: name_part(name, "addition"), prefix: name_part(name, "prefix")
        )
      end

      def fetch_affiliation(elm)
        org = get_org elm.at("./organization")
        desc = elm.xpath("./description").map do |e|
          FormattedString.new(content: e.text, language: e[:language],
                              script: e[:script], format: e[:format])
        end
        name = localized_string elm.at("./name")
        Affiliation.new organization: org, description: desc, name: name
      end

      def localized_string(elm)
        return unless elm

        LocalizedString.new(elm.text, elm[:language], elm[:script])
      end

      #
      # Parse contact information
      #
      # @param [Nokogiri::XML::Element] contrib contributor element
      #
      # @return [Array<RelatonBib::Address, RelatonBib::Contact>] contacts
      #
      def parse_contact(contrib)
        contrib.xpath("./address|./phone|./email|./uri").map do |c|
          parse_address(c) || Contact.new(type: c.name, value: c.text, subtype: c[:type])
        end
      end

      #
      # Parse address
      #
      # @param [Nokogiri::XML::Element] contact contact element
      #
      # @return [RelatonBib::Address] address
      #
      def parse_address(contact) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
        return unless contact.name == "address"

        Address.new(
          street: contact.xpath("./street").map(&:text),
          city: contact.at("./city")&.text,
          state: contact.at("./state")&.text,
          country: contact.at("./country")&.text,
          postcode: contact.at("./postcode")&.text,
          formatted_address: contact.at("./formattedAddress")&.text,
        )
      end

      #
      # Parse initials
      #
      # @param [Nokogiri::XML::Element] name person name element
      #
      # @return [RelatonBib::LocalizedString, nil] initials
      #
      def parse_initials(name)
        localized_string name.at("./formatted-initials")
      end

      #
      # Parse forename
      #
      # @param [Nokogiri::XML::Element] name person name element
      #
      # @return [Array<RelatonBib::Forename>] forenames
      #
      def parse_forename(name)
        name.xpath("./forename").map do |np|
          args = np.attributes.each_with_object({}) { |(k, v), h| h[k.to_sym] = v.to_s }
          args[:content] = np.text
          Forename.new(**args)
        end
      end

      #
      # Parse name part
      #
      # @param [Nokogiri::XML::Element] name person name element
      # @param [String] part name part
      #
      # @return [Array<RelatonBib::LocalizedString>] name parts
      #
      def name_part(name, part)
        name.xpath("./#{part}").map { |np| localized_string np }
      end

      # @param item [Nokogiri::XML::Element]
      # @return [Array<RelatonBib::ContributionInfo>]
      def fetch_contributors(item)
        item.xpath("./contributor").map { |c| fetch_contribution_info c }
      end

      def fetch_contribution_info(contrib)
        entity = get_org(contrib.at("./organization")) || get_person(contrib.at("./person"))
        role = contrib.xpath("./role").map do |r|
          { type: r[:type], description: r.xpath("./description").map(&:text) }
        end
        ContributionInfo.new entity: entity, role: role
      end

      # @param item [Nokogiri::XML::Element]
      # @return [Array<RelatonBib::FormattedString>]
      def fetch_abstract(item)
        item.xpath("./abstract").map do |a|
          c = a.children.to_xml(encoding: "utf-8").strip
          FormattedString.new(content: c, language: a[:language],
                              script: a[:script], format: a[:format])
        end
      end

      # @param item [Nokogiri::XML::Element]
      # @return [Array<RelatonBib::CopyrightAssociation>]
      def fetch_copyright(item)
        item.xpath("./copyright").map do |cp|
          owner = cp.xpath("owner").map { |o| fetch_contribution_info o }
          from = cp.at("from")&.text
          to   = cp.at("to")&.text
          scope = cp.at("scope")&.text
          CopyrightAssociation.new(owner: owner, from: from, to: to, scope: scope)
        end
      end

      # @param item [Nokogiri::XML::Element]
      # @return [Arra<RelatonBib::TypedUri>]
      def fetch_link(item)
        item.xpath("./uri").map do |l|
          TypedUri.new(type: l[:type], content: l.text, language: l[:language],
                       script: l[:script])
        end
      end

      # @param item [Nokogiri::XML::Element]
      # @param klass [RelatonBib::DocumentRelation.class,
      #   RelatonNist::DocumentRelation.class]
      # @return [Array<RelatonBib::DocumentRelation>]
      def fetch_relations(item, klass = DocumentRelation)
        item.xpath("./relation").map do |rel|
          klass.new(
            type: rel[:type].nil? || rel[:type].empty? ? nil : rel[:type],
            description: relation_description(rel),
            bibitem: bib_item(item_data(rel.at("./bibitem"))),
            locality: localities(rel),
            source_locality: source_localities(rel),
          )
        end
      end

      # @param rel [Nokogiri::XML::Element]
      # @return [RelatonBib::FormattedString, nil]
      def relation_description(rel)
        d = rel.at "./description"
        return unless d

        FormattedString.new(content: d.text, language: d[:language],
                            script: d[:script], format: d[:format])
      end

      #
      # Create bibliographic item
      #
      # @param item_hash [Hash] bibliographic item hash
      #
      # @return [RelatonBib::BibliographicItem] bibliographic item
      #
      def bib_item(item_hash)
        BibliographicItem.new(**item_hash)
      end

      #
      # Parse locality
      #
      # @param rel [Nokogiri::XML::Element] relation element
      #
      # @return [Array<RelatonBib::Locality, RelatonBib::LocalityStack>] localities
      #
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
      # @param klass [RelatonBib::Locality, RelatonBib::LocalityStack]
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
        rel.xpath("./sourceLocality|./sourceLocalityStack").map do |loc|
          if loc.name == "sourceLocality"
            # src_locs = loc.xapth("./sourceLocality").map { |sl| locality(sl, SourceLocality) }
            # SourceLocalityStack.new src_locs
            locality loc, SourceLocality
          else
            sls = loc.xpath("./sourceLocality").map { |l| locality l, SourceLocality }
            SourceLocalityStack.new sls
          end
        end
      end

      # @param item [Nokogiri::XML::Element]
      # @return [RelatonBib::FormattedRef, nil]
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
