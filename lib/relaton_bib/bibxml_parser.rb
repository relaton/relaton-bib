module RelatonBib
  module BibXMLParser
    SERIESINFONAMES = ["DOI", "Internet-Draft"].freeze
    FLAVOR = nil

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
      # sfid = reference.at("./seriesInfo[@name='#{self::FLAVOR}']",
      #                     "./front/seriesInfo[@name='#{self::FLAVOR}']")
      # if sfid
      #   type = sfid[:name]
      #   id = sfid[:value]
      #   # scope = "series"
      # else # if self::FLAVOR
        # id, scope = if reference[:anchor] then [reference[:anchor], "anchor"]
        #             elsif reference[:docName] then [reference[:docName], "docName"]
        #             elsif reference[:number] then [reference[:number], "number"]
        #             end
      id = reference["anchor"] || reference["docName"] || reference["number"]
      type_match = id&.match(/^(3GPP|W3C|[A-Z]{2,})(?:\.(?=[A-Z])|(?=\d))/)
      type = self::FLAVOR || (type_match && type_match[1])
      if id
        /^(?<pref>I-D|3GPP|W3C|[A-Z]{2,})[._]?(?<num>.+)/ =~ id
        num.sub!(/^-?0+/, "") if %w[RFC BCP FYI STD].include?(pref)
        pid = pref ? "#{pref} #{num}" : id
        ret << DocumentIdentifier.new(type: type, id: pid)
      end
      %w[anchor docName number].each do |atr|
        if reference[atr]
          ret << DocumentIdentifier.new(id: reference[atr], type: type, scope: atr)
        end
      end
      # end
      # if id
      #   ret << DocumentIdentifier.new(type: type, id: id)
      #   ret << DocumentIdentifier.new(type: type, id: id, scope: scope) if scope
      # end
      # if (id = reference[:anchor])
      #   ret << DocumentIdentifier.new(type: "rfc-anchor", id: id)
      # end
      ret + reference.xpath("./seriesInfo", "./front/seriesInfo").map do |si|
        next unless SERIESINFONAMES.include? si[:name]

        id = si[:value]
        id.sub!(/(?<=-)\d{2}$/, ver) if ver && si[:name] == "Internet-Draft"
        DocumentIdentifier.new(id: id, type: si[:name])
      end.compact
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
        c = a.children.to_s.gsub(/\s*(<\/?)t(>)\s*/, '\1p\2')
          .gsub(/[\t\n]/, " ").squeeze " "
        FormattedString.new(content: c, language: language(ref), script: "Latn",
                            format: "text/html")
      end
    end

    # @param reference [Nokogiri::XML::Element]
    # @return [Array<Hash>]
    def contributors(reference)
      reference.xpath("./front/author").map do |contrib|
        if contrib[:fullname] || contrib[:surname] then person(contrib, reference)
        else organization(contrib)
        end
      end.compact
      # persons(reference) + organizations(reference)
    end

    # @param author [Nokogiri::XML::Element]
    # @param reference [Nokogiri::XML::Element]
    # @return [Array<Hash{Symbol=>RelatonBib::Person,Symbol=>Array<String>}>]
    def person(author, reference)
      # reference.xpath("./front/author[@surname]|./front/author[@fullname]")
      #   .map do |author|
      entity = Person.new(
        name: full_name(author, reference),
        affiliation: affiliation(author),
        contact: contacts(author.at("./address")),
      )
      { entity: entity, role: [contributor_role(author)] }
      # end
    end

    # @param contrib [Nokogiri::XML::Element]
    # @return [Array<Hash{Symbol=>RelatonBib::Organization,
    #   Symbol=>Array<String>}>]
    def organization(contrib)
      # publisher = { entity: new_org, role: [type: "publisher"] }
      # orgs = reference.xpath("./seriesinfo").reduce([]) do |mem, si|
      #   next mem unless si[:stream]

      #   mem << { entity: new_org(si[:stream], nil), role: [type: "author"] }
      # end
      # orgs + reference.xpath(
      #   "front/author[not(@surname)][not(@fullname)]/organization",
      # ).map do |org|
      org = contrib.at("./organization")
      { entity: new_org(org.text, org[:abbrev]), role: [contributor_role(contrib)] }
      # end
    end

    # @param author [Nokogiri::XML::Element]
    # @param reference [Nokogiri::XML::Element]
    # @return [RelatonBib::FullName]
    def full_name(author, reference)
      lang = language reference
      FullName.new(
        completename: localized_string(author[:fullname], lang),
        initial: [localized_string(author[:initials], lang)].compact,
        surname: localized_string(author[:surname], lang),
      )
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
    # @param abbr [String]
    # @return [RelatonBib::Organization]
    def new_org(name, abbr)
      # (name = "Internet Engineering Task Force", abbr = "IETF")
      Organization.new name: name, abbreviation: abbr
    end

    # @param content [String, nil]
    # @param lang [String, nil]
    # @return [RelatonBib::LocalizedString, nil]
    def localized_string(content, lang)
      LocalizedString.new(content, lang) if content
    end

    # @param postal [Nokogiri::XML::Element]
    # @return [Array<RelatonBib::Address, RelatonBib::Phone>]
    def contacts(addr)
      conts = []
      return conts unless addr

      postal = addr.at("./postal")
      conts << address(postal) if postal
      add_contact(conts, "phone", addr.at("./phone"))
      add_contact(conts, "email", addr.at("./email"))
      add_contact(conts, "uri", addr.at("./uri"))
      conts
    end

    # @param postal [Nokogiri::XML::Element]
    # @rerurn [RelatonBib::Address]
    def address(postal) # rubocop:disable Metrics/CyclomaticComplexity
      street = [
        (postal.at("./postalLine") || postal.at("./street"))&.text,
      ].compact
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
    def dates(reference)
      return unless (date = reference.at "./front/date")

      d = [date[:year], month(date[:month]), (date[:day] || 1)].compact.join "-"
      date = Time.parse(d).strftime "%Y-%m-%d"
      [BibliographicDate.new(type: "published", on: date)]
    rescue ArgumentError
      []
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
      return 1 if !mon || mon.empty?
      return mon if /^\d+$/.match? mon

      Date::MONTHNAMES.index(mon)
    end

    #
    # Extract series form reference
    # @param reference [Nokogiri::XML::Element]
    #
    # @return [Array<RelatonBib::Series>]
    #
    def series(reference)
      reference.xpath("./seriesInfo", "./front/seriesInfo").map do |si|
        next if si[:name] == "DOI" || si[:stream] || si[:status]

        t = TypedTitleString.new(
          content: si[:name], language: language(reference), script: "Latn",
        )
        Series.new(title: t, number: si[:value], type: "main")
      end.compact
    end

    # @param anchor [String]
    # @return [String]
    def doctype(anchor)
      case anchor
      when /I-D/ then "internet-draft"
      when /IEEE/ then "ieee"
      else "rfc"
      end
    end

    extend BibXMLParser
  end
end