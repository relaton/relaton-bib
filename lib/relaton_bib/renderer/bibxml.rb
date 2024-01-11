module RelatonBib
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
        target = @bib.link.detect { |l| l.type.casecmp("src").zero? } ||
          @bib.link.detect { |l| l.type.casecmp("doi").zero? }
        bxml = if @bib.docnumber&.match(/^BCP/) || (@bib.docidentifier.detect(&:primary)&.id ||
                    @bib.docidentifier[0].id).include?("BCP")
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
              xml.title @bib.title[0].title.content if @bib.title.any?
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

          h[di.scope.to_sym] = di.id
        end
        return attrs if attrs.any?

        @bib.docidentifier.first&.tap do |di|
          anchor = di.type == "IANA" ? di.id.split[1..].join(" ").upcase : di.id
          return { anchor: anchor.gsub(" ", ".") }
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
            if c.entity.is_a?(Person) then render_person xml, c.entity
            else render_organization xml, c.entity, c.role
            end
            render_address xml, c
          end
        end
      end

      #
      # Render address
      #
      # @param [Nokogiri::XML::Builder] builder xml builder
      # @param [RelatonBib::ContributionInfo] contrib contributor
      #
      def render_address(builder, contrib) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        address, contact = address_contact contrib.entity.contact
        if address || contact.any?
          builder.address do |xml|
            # address = contrib.entity.contact.detect { |cn| cn.is_a? Address }
            if address
              xml.postal do
                xml.city address.city if address.city
                xml.code address.postcode if address.postcode
                xml.country address.country if address.country
                xml.region address.state if address.state
                xml.street address.street[0] if address.street.any?
              end
            end
            render_contact xml, contact
          end
        end
      end

      def address_contact(contact) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
        addr = contact.detect do |c|
          c.is_a?(Address) && (c.city || c.postcode || c.country || c.state || c.street.any?)
        end
        cont = contact.select { |c| c.is_a?(Contact) }
        [addr, cont]
      end

      #
      # Render contact
      #
      # @param [Nokogiri::XML::Builder] builder xml builder
      # @param [Array<RelatonBib::Address, RelatonBib::Contact>] addr contact
      #
      def render_contact(builder, addr)
        %w[phone email uri].each do |type|
          cont = addr.detect { |cn| cn.is_a?(Contact) && cn.type == type }
          builder.send type, cont.value if cont
        end
      end

      #
      # Render person
      #
      # @param [Nokogiri::XML::Builder] builder xml builder
      # @param [RelatonBib::Person] person person
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
      # @param [RelatonBib::Organization] org organization
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
            builder.seriesInfo(name: di.type, value: di.id)
          end
        end
        # di_types = docidentifier.map(&:type)
        @bib.series.select do |s|
          s.title && # !di_types.include?(s.title.title.to_s) &&
            !BibXMLParser::SERIESINFONAMES.include?(s.title.title.to_s)
        end.uniq { |s| s.title.title.to_s }.each do |s|
          si = builder.seriesInfo(name: s.title.title.to_s)
          si[:value] = s.number if s.number
        end
      end

      def render_format(builder)
        @bib.link.select { |l| l.type == "TXT" }.each do |l|
          builder.format type: l.type, target: l.content
        end
      end
    end
  end
end
