module RelatonBib
  module BibXMLParser
    # SeriesInfo what should be saved as docidentifiers in the Relaton model.
    SERIESINFONAMES = ["DOI"].freeze
    RFCPREFIXES = %w[RFC BCP FYI STD].freeze

    FLAVOR = nil

    ORGNAMES = {
      "IEEE" => "Institute of Electrical and Electronics Engineers",
      "W3C" => "World Wide Web Consortium",
      "3GPP" => "3rd Generation Partnership Project",
    }.freeze

    #
    # Parse BibXML content
    #
    # @param [String] bibxml content
    # @param [String, nil] url source URL
    # @param [Boolean] is_relation true if the content is relation item
    # @param [String, nil] ver version
    #
    # @return [<Type>] <description>
    #
    def parse(bibxml, url: nil, is_relation: false, ver: nil)
      doc = Nokogiri::XML bibxml
      fetch_rfc doc.at("/referencegroup", "/reference"), url: url, is_relation: is_relation, ver: ver
    end

    # @param reference [Nokogiri::XML::Element, nil]
    # @param is_relation [Boolean] don't add fetched date for relation if true
    # @param url [String, nil]
    # @param ver [String, nil] Internet Draft version
    # @return [RelatonBib::BibliographicItem]
    def fetch_rfc(reference, is_relation: false, url: nil, ver: nil) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      return unless reference

      hash = {
        is_relation: is_relation,
        docnumber: docnumber(reference),
        type: "standard",
        docid: docids(reference, ver),
        status: status(reference),
        language: [language(reference)],
        script: ["Latn"],
        link: link(reference, url, ver),
        title: titles(reference),
        formattedref: formattedref(reference),
        abstract: abstracts(reference),
        contributor: contributors(reference),
        relation: relations(reference),
        date: dates(reference),
        editorialgroup: editorialgroup(reference),
        series: series(reference),
        keyword: reference.xpath("front/keyword").map(&:text),
        doctype: doctype(reference[:anchor]),
      }
      # hash[:fetched] = Date.today.to_s unless is_relation
      bib_item(**hash)
    end

    def docnumber(reference)
      reference[:anchor]&.sub(/^\w+\./, "")
    end

    # @param attrs [Hash]
    # @return [RelatonBib::BibliographicItem]
    def bib_item(**attrs)
      # attrs[:place] = ["Fremont, CA"]
      BibliographicItem.new(**attrs)
    end

    # @param reference [Nokogiri::XML::Element]
    # @return [String]
    def language(reference)
      reference[:lang] || "en"
    end

    #
    # Extract document identifiers from reference
    #
    # @param reference [Nokogiri::XML::Element]
    # @param ver [String, nil] Internet Draft version
    #
    # @return [Array<RelatonBib::DocumentIdentifier>]
    #
    def docids(reference, ver) # rubocop:disable Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/AbcSize
      ret = []
      si = reference.at("./seriesInfo[@name='Internet-Draft']",
                        "./front/seriesInfo[@name='Internet-Draft']")
      if si
        id = si[:value]
        id.sub!(/(?<=-)\d{2}$/, ver) if ver
        ret << DocumentIdentifier.new(type: "Internet-Draft", id: id, primary: true)
      else
        id = reference[:anchor] || reference[:docName] || reference[:number]
        ret << create_docid(id, ver) if id
      end

      %w[anchor docName number].each do |atr|
        if reference[atr]
          pref, num = id_to_pref_num reference[atr]
          atrid = if atr == "anchor" && RFCPREFIXES.include?(pref)
                    "#{pref}#{num.sub(/^-?0+/, '')}"
                  else
                    reference[atr]
                  end
          type = pubid_type id
          ret << DocumentIdentifier.new(id: atrid, type: type, scope: atr)
        end
      end

      ret + reference.xpath("./seriesInfo", "./front/seriesInfo").map do |si|
        next unless SERIESINFONAMES.include? si[:name]

        id = si[:value]
        # id.sub!(/(?<=-)\d{2}$/, ver) if ver && si[:name] == "Internet-Draft"
        DocumentIdentifier.new(id: id, type: si[:name])
      end.compact
    end

    def create_docid(id, ver) # rubocop:disable Metrics/MethodLength
      pref, num = id_to_pref_num(id)
      if RFCPREFIXES.include?(pref)
        pid = "#{pref} #{num.sub(/^-?0+/, '')}"
        type = pubid_type id
      elsif %w[I-D draft].include?(pref)
        pid = "draft-#{num}"
        pid.sub!(/(?<=-)\d{2}$/, ver) if ver
        type = "Internet-Draft"
      else
        pid = pref ? "#{pref} #{num}" : id
        type = pubid_type id
      end
      DocumentIdentifier.new(type: type, id: pid, primary: true)
    end

    def id_to_pref_num(id)
      tn = /^(?<pref>I-D|draft|3GPP|W3C|[A-Z]{2,})[._-]?(?<num>.+)/.match id
      tn && tn.to_a[1..2]
    end

    #
    # Extract document identifier type from identifier
    #
    # @param [String] id identifier
    #
    # @return [String]
    #
    def pubid_type(id)
      id_to_pref_num(id)&.first
    end

    #
    # extract status
    # @param reference [Nokogiri::XML::Element]
    #
    # @return [RelatonBib::DocumentStatus]
    #
    def status(reference)
      st = reference.at("./seriesinfo[@status]")
      DocumentStatus.new(stage: st[:status]) if st
    end

    # @param reference [Nokogiri::XML::Element]
    # @param url [String]
    # @param ver [String, nil] Internet Draft version
    # @return [Array<Hash>]
    def link(reference, url, ver)
      l = []
      l << { type: "xml", content: url } if url
      l << { type: "src", content: reference[:target] } if reference[:target]
      if /^I-D/.match? reference[:anchor]
        reference.xpath("format").each do |f|
          c = ver ? f[:target].sub(/(?<=-)\d{2}(?=\.)/, ver) : f[:target]
          l << { type: f[:type], content: c }
        end
      end
      l
    end

    # @param reference [Nokogiri::XML::Element]
    # @return [Array<Hash>]
    def titles(reference)
      reference.xpath("./front/title").map do |title|
        { content: title.text, language: language(reference), script: "Latn" }
      end
    end

    # @param reference [Nokogiri::XML::Element]
    # @return [RelatonBib::FormattedRef, nil]
    def formattedref(reference)
      return if reference.at "./front/title"

      cont = (reference[:anchor] || reference[:docName] || reference[:number])
      if cont
        FormattedRef.new(
          content: cont, language: language(reference), script: "Latn",
        )
      end
    end

    # @param reference [Nokogiri::XML::Element]
    # @return [Array<RelatonBib::FormattedString>]
    def abstracts(ref)
      ref.xpath("./front/abstract").map do |a|
        c = a.inner_html.gsub(/\s*(<\/?)t(>)\s*/, '\1p\2')
          .gsub(/[\t\n]/, " ").squeeze " "
        FormattedString.new(content: c, language: language(ref), script: "Latn",
                            format: "text/html")
      end
    end

    # @param reference [Nokogiri::XML::Element]
    # @return [Array<Hash>]
    def contributors(reference)
      lang = language reference
      reference.xpath("./front/author").map do |contrib|
        entity = person(contrib, lang) || organization(contrib)
        next unless entity

        { entity: entity, role: [contributor_role(contrib)] }
      end.compact
    end

    # @param author [Nokogiri::XML::Element]
    # @param lang [String]
    # @return [RelatonBib::Person, nil]
    def person(author, lang)
      return unless author[:fullname] || author[:surname]

      name = full_name(author[:fullname], author[:surname], author[:initials], lang)
      Person.new(name: name, affiliation: affiliation(author),
                 contact: contacts(author.at("./address")))
    end

    # @param contrib [Nokogiri::XML::Element]
    # @return [RelatonBib::Organization, nil]
    def organization(contrib)
      org = contrib.at("./organization")
      return unless org

      orgname = org.text.strip
      return if orgname.empty?

      name = ORGNAMES[orgname] || orgname
      new_org name, org[:abbrev]
    end

    # @param fname [String] full name
    # @param sname [String] surname
    # @param inits [String] initials
    # @param lang [String] language
    # @return [RelatonBib::FullName]
    def full_name(fname, sname, inits, lang)
      initials = localized_string(inits, lang) if inits
      FullName.new(
        completename: localized_string(fname, lang), initials: initials,
        forename: forename(inits, lang), surname: localized_string(sname, lang)
      )
    end

    #
    # Create forenames with initials
    #
    # @param [String] initials initials
    # @param [String] lang language
    #
    # @return [Array<RelatonBib::Forename>] forenames
    #
    def forename(initials, lang = nil, script = nil)
      return [] unless initials

      initials.split(/\.-?\s?|\s/).map do |i|
        Forename.new(initial: i, language: lang, script: script)
      end
    end

    # @param author [Nokogiri::XML::Element]
    # @return [Array<RelatonBib::Affiliation>]
    def affiliation(author)
      o = author.at("./organization")
      return [] if o.nil? || o.text.empty?

      org = new_org o.text, o[:abbrev]
      [Affiliation.new(organization: org)]
    end

    # @param name [String]
    # @param abbr [String, nil]
    # @return [RelatonBib::Organization]
    def new_org(name, abbr = nil)
      Organization.new name: name, abbreviation: abbr
    end

    # @param content [String, nil]
    # @param lang [String, nil]
    # @param script [String, nil]
    # @return [RelatonBib::LocalizedString, nil]
    def localized_string(content, lang, script = nil)
      LocalizedString.new(content, lang, script) if content
    end

    # @param postal [Nokogiri::XML::Element]
    # @return [Array<RelatonBib::Address, RelatonBib::Phone>]
    def contacts(addr)
      conts = []
      return conts unless addr

      postal = addr.at("./postal")
      conts << address(postal) if postal&.at("./city") && postal&.at("./country")
      add_contact(conts, "phone", addr.at("./phone"))
      add_contact(conts, "email", addr.at("./email"))
      add_contact(conts, "uri", addr.at("./uri"))
      conts
    end

    # @param postal [Nokogiri::XML::Element]
    # @rerurn [RelatonBib::Address]
    def address(postal) # rubocop:disable Metrics/CyclomaticComplexity
      street = [postal.at("./postalLine | ./street")&.text].compact
      Address.new(
        street: street,
        city: postal.at("./city")&.text,
        postcode: postal.at("./code")&.text,
        country: postal.at("./country")&.text,
        state: postal.at("./region")&.text,
      )
    end

    # @param conts [Array<RelatonBib::Address, RelatonBib::Contact>]
    # @param type [String] allowed "phone", "email" or "uri"
    # @param value [String]
    def add_contact(conts, type, value)
      conts << Contact.new(type: type, value: value.text) if value
    end

    # @param author [Nokogiri::XML::Document]
    # @return [Hash]
    def contributor_role(author)
      { type: author[:role] || "author" }
    end

    # @param reference [Nokogiri::XML::Element]
    # @return [Hash]
    def relations(reference)
      reference.xpath("reference").map do |ref|
        { type: "includes", bibitem: fetch_rfc(ref, is_relation: true) }
      end
    end

    #
    # Extract date from reference.
    #
    # @param reference [Nokogiri::XML::Element]
    # @return [Array<RelatonBib::BibliographicDate>] published data.
    #
    def dates(reference) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize
      date = reference.at "./front/date"
      return [] if date.nil? || date[:year].nil? || date[:year].empty?

      d = date[:year]
      d += "-#{month(date[:month])}" if date[:month] && !date[:month].empty?
      d += "-#{date[:day]}" if date[:day]
      # date = Time.parse(d).strftime "%Y-%m-%d"
      [BibliographicDate.new(type: "published", on: d)]
    end

    # @param reference [Nokogiri::XML::Element]
    # @return [RelatonBib::EditorialGroup, nil]
    def editorialgroup(reference)
      tc = reference.xpath("./front/workgroup").map do |ed|
        wg = WorkGroup.new name: ed.text
        committee wg
      end
      EditorialGroup.new tc if tc.any?
    end

    # @param [RelatonBib::WorkGroup]
    # @return [RelatonBib::TechnicalCommittee]
    def committee(wgr)
      TechnicalCommittee.new wgr
    end

    def month(mon)
      # return 1 if !mon || mon.empty?
      return mon if /^\d+$/.match? mon

      Date::MONTHNAMES.index { |m| m&.include? mon }.to_s.rjust 2, "0"
    end

    #
    # Extract series form reference
    # @param reference [Nokogiri::XML::Element]
    #
    # @return [Array<RelatonBib::Series>]
    #
    def series(reference)
      reference.xpath("./seriesInfo", "./front/seriesInfo").map do |si|
        next if SERIESINFONAMES.include?(si[:name]) || si[:stream] || si[:status]

        t = TypedTitleString.new(
          content: si[:name], language: language(reference), script: "Latn",
        )
        Series.new(title: t, number: si[:value], type: "main")
      end.compact
    end

    # @param anchor [String]
    # @return [String]
    def doctype(anchor)
      type =  case anchor
              when /I-D/ then "internet-draft"
              when /IEEE/ then "ieee"
              else "rfc"
              end
      DocumentType.new type: type
    end

    extend BibXMLParser
  end
end
