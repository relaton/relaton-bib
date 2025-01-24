module Relaton
  module Renderer
    class BibXML
      def initialize(bib)
        @bib = bib
      end

      #
      # Render BibXML (RFC)
      #
      # @param [Nokogiri::XML::Builder, nil] builder
      # @param [Boolean] include_keywords (false)
      #
      # @return [String, Nokogiri::XML::Builder::NodeBuilder] XML
      #
      def render(builder: nil, include_keywords: true)
        if builder
          render_bibxml builder, include_keywords
        else
          Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
            render_bibxml xml, include_keywords
          end.doc.root.to_xml
        end
      end

      #
      # Render BibXML (RFC, BCP)
      #
      # @param [Nokogiri::XML::Builder] builder
      # @param [Boolean] include_bibdata
      #
      def render_bibxml(builder, include_keywords) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        target = @bib.source.detect { |l| l.type.casecmp("src").zero? } ||
          @bib.source.detect { |l| l.type.casecmp("doi").zero? }
        bxml = if @bib.docnumber&.match(/^BCP/) ||
            (@bib.docidentifier.detect(&:primary) || @bib.docidentifier[0])&.content&.include?("BCP")
                 render_bibxml_refgroup(builder, include_keywords)
               else
                 render_bibxml_ref(builder, include_keywords)
               end
        bxml[:target] = target.content.to_s if target
      end

      #
      # Render BibXML (BCP)
      #
      # @param [Nokogiri::XML::Builder] builder
      # @param [Boolean] include_keywords
      #
      def render_bibxml_refgroup(builder, include_keywords)
        builder.referencegroup(**ref_attrs) do |b|
          @bib.relation.each do |r|
            r.bibitem.to_bibxml(b, include_keywords: include_keywords) if r.type == "includes"
          end
        end
      end

      #
      # Render BibXML (RFC)
      #
      # @param [Nokogiri::XML::Builder] builder
      # @param [Boolean] include_keywords
      #
      def render_bibxml_ref(builder, include_keywords) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
        builder.reference(**ref_attrs) do |xml|
          if @bib.title.any? || @bib.contributor.any? || @bib.date.any? || @bib.abstract.any? ||
              @bib.editorialgroup&.technical_committee&.any? ||
              (include_keywords && @bib.keyword.any?)
            xml.front do
              xml.title @bib.title[0].content if @bib.title.any?
              render_authors xml
              render_date xml
              render_workgroup xml
              render_keyword xml if include_keywords
              render_abstract xml
            end
          end
          render_seriesinfo xml
          render_format xml
        end
      end

      #
      # Create reference attributes
      #
      # @return [Hash<Symbol=>String>] attributes
      #
      def ref_attrs # rubocop:disable Metrics/AbcSize
        discopes = %w[anchor docName number]
        attrs = @bib.docidentifier.each_with_object({}) do |di, h|
          next unless discopes.include?(di.scope)

          h[di.scope.to_sym] = di.content
        end
        return attrs if attrs.any?

        @bib.docidentifier.first&.tap do |di|
          anchor = di.type == "IANA" ? di.content.split[1..].join(" ").upcase : di.content
          return { anchor: anchor.tr(" ", ".") }
        end
      end

      #
      # Render authors
      #
      # @param [Nokogiri::XML::Builder] builder xml builder
      #
      def render_authors(builder) # rubocop:disable Metrics/AbcSize
        @bib.contributor.each do |c|
          builder.author do |xml|
            xml.parent[:role] = "editor" if c.role.detect { |r| r.type == "editor" }
            if c.entity.is_a?(Bib::Person) then render_person xml, c.entity
            else render_organization xml, c.entity, c.role
            end
            render_address xml, c.entity
          end
        end
      end

      #
      # Render address
      #
      # @param [Nokogiri::XML::Builder] builder xml builder
      # @param [Relaton::Bib::ContributionInfo] contrib contributor
      #
      def render_contacts(builder, contrib)
        # address, contact = address_contact contrib.entity.contact
        # if address || contact.any?
        # contrib.entity.address.each { |address| render_address builder, address }
        # render_contact builder, contrib.entity
        render_address builder, contrib.entity
      end

      def render_address(builder, entity) # rubocop:disable Metrics/AbcSize
        return unless entity.address.any? || entity.phone.any? || entity.email.any? || entity.uri.any?

        builder.address do |xml|
          render_postal xml, entity.address
          render_contact xml, entity.phone.first, "phone"
          xml.email entity.email.first if entity.email.any?
          render_contact xml, entity.uri.first, "uri"
        end
      end

      def render_postal(builder, address) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
        addr = address.find do |a|
          a.city || a.postcode || a.country || a.state || a.street.any?
        end

        if addr
          builder.postal do |xml|
            xml.city addr.city if addr.city
            xml.code addr.postcode if addr.postcode
            xml.country addr.country if addr.country
            xml.region addr.state if addr.state
            xml.street addr.street[0] if addr.street.any?
          end
          return
        end

        address.select(&:formatted_address).each do |a|
          builder.postalLine a.formatted_address
        end
      end

      def render_contact(builder, contact, type)
        return unless contact

        builder.send type, contact.content
      end

      # def address_contact(contact) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      #   addr = contact.detect do |c|
      #     c.is_a?(Address) && (c.city || c.postcode || c.country || c.state || c.street.any?)
      #   end
      #   cont = contact.select { |c| c.is_a?(Contact) }
      #   [addr, cont]
      # end

      #
      # Render contact
      #
      # @param [Nokogiri::XML::Builder] builder xml builder
      # @param [Array<Relaton::Bib::Address, Relaton::Bib::Contact>] addr contact
      #
      # def render_contact(builder, entity)
      #   %w[phone email uri].each do |type|
      #     entity.send(type).each do |cont|
      #       # cont = addr.detect { |cn| cn.is_a?(Contact) && cn.type == type }
      #       builder.send type, cont.value # if cont
      #     end
      #   end
      # end

      #
      # Render person
      #
      # @param [Nokogiri::XML::Builder] builder xml builder
      # @param [Relaton::Bib::Person] person person
      #
      def render_person(builder, person) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        render_organization builder, person.affiliation.first&.organization
        if person.name.completename
          builder.parent[:fullname] = person.name.completename.content
        elsif person.name.forename.any?
          builder.parent[:fullname] = person.name.forename.map do |n|
            n.content || n.initial
          end.join " "
        end
        if person.name.initials
          builder.parent[:initials] = person.name.initials.content
        elsif person.name.forename.any?
          builder.parent[:initials] = person.name.forename.map do |f|
            "#{f.initial || f.content[0]}."
          end.join
        end
        if person.name.surname
          if !person.name.completename && person.name.forename.any? && person.name.surname
            builder.parent[:fullname] += " #{person.name.surname}"
          end
          builder.parent[:surname] = person.name.surname.content
        end
      end

      #
      # Render organization
      #
      # @param [Nokogiri::XML::Builder] builder xml builder
      # @param [Relaton::Bib::Organization] org organization
      #
      def render_organization(builder, org, _role = []) # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/AbcSize
        abbrev = org&.abbreviation&.content
        orgname = org&.name&.first&.content
        orgname = if BibXMLParser::ORGNAMES.key?(abbrev) then abbrev
                  else BibXMLParser::ORGNAMES.key(orgname) || orgname || abbrev
                  end
        # if role.detect { |r| r.description.detect { |d| d.content == "BibXML author" } }
        #   builder.parent[:fullname] = orgname
        # else
        org = builder.organization orgname
        org[:abbrev] = abbrev if abbrev
        # end
      end

      #
      # Render date
      #
      # @param [Nokogiri::XML::Builder] builder xml builder
      #
      def render_date(builder) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
        dt = @bib.date.detect { |d| d.type == "published" }
        return unless dt

        elm = builder.date
        y = dt.on(:year) || dt.from(:year) || dt.to(:year)
        elm[:year] = y if y
        m = dt.on(:month) || dt.from(:month) || dt.to(:month)
        elm[:month] = Date::MONTHNAMES[m] if m
        # rfcs = %w[RFC BCP FYI STD]
        # unless rfcs.include?(doctype) && docidentifier.detect { |di| rfcs.include? di.type }
        d = dt.on(:day) || dt.from(:day) || dt.to(:day)
        elm[:day] = d if d
        # end
      end

      #
      # Render workgroup
      #
      # @param [Nokogiri::XML::Builder] builder xml builder
      #
      def render_workgroup(builder)
        @bib.editorialgroup&.technical_committee&.each do |tc|
          builder.workgroup tc.workgroup.name
        end
      end

      #
      # Render keyword
      #
      # @param [Nokogiri::XML::Builder] builder xml builder
      #
      def render_keyword(builder)
        @bib.keyword.each { |kw| builder.keyword kw.content }
      end

      #
      # Render abstract
      #
      # @param [Nokogiri::XML::Builder] builder xml builder
      #
      def render_abstract(builder)
        return unless @bib.abstract.any?

        builder.abstract { |xml| xml << @bib.abstract[0].content.gsub(/(<\/?)p(>)/, '\1t\2') }
      end

      #
      # Render seriesinfo
      #
      # @param [Nokogiri::XML::Builder] builder xml builder
      #
      def render_seriesinfo(builder) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        @bib.docidentifier.each do |di|
          if BibXMLParser::SERIESINFONAMES.include?(di.type) && di.scope != "trademark"
            builder.seriesInfo(name: di.type, value: di.content)
          end
        end

        @bib.series.select do |s|
          s.title.reject { |t| BibXMLParser::SERIESINFONAMES.include?(t.content) }.any?
        end.uniq do |s|
          s.title.find { |t| !BibXMLParser::SERIESINFONAMES.include?(t.content)}.content
        end.each do |s|
          title = s.title.find { |t| !BibXMLParser::SERIESINFONAMES.include?(t.content) }
          si = builder.seriesInfo(name: title.content)
          si[:value] = s.number if s.number
        end
      end

      def render_format(builder)
        @bib.source.select { |l| l.type == "TXT" }.each do |l|
          builder.format type: l.type, target: l.content
        end
      end
    end
  end
end
