module RelatonBib
  class HashConverter
    class << self
      def hash_to_bib(args, nested = false)
        return nil unless args.is_a?(Hash)

        ret = Marshal.load(Marshal.dump(symbolize(args))) # deep copy
        timestamp_hash(ret) unless nested
        title_hash_to_bib(ret)
        link_hash_to_bib(ret)
        language_hash_to_bib(ret)
        script_hash_to_bib(ret)
        dates_hash_to_bib(ret)
        docid_hash_to_bib(ret)
        version_hash_to_bib(ret)
        biblionote_hash_to_bib(ret)
        abstract_hash_to_bib(ret)
        formattedref_hash_to_bib(ret)
        docstatus_hash_to_bib(ret)
        contributors_hash_to_bib(ret)
        relations_hash_to_bib(ret)
        series_hash_to_bib(ret)
        medium_hash_to_bib(ret)
        place_hash_to_bib(ret)
        extent_hash_to_bib(ret)
        accesslocation_hash_to_bib(ret)
        classification_hash_to_bib(ret)
        validity_hash_to_bib(ret)
        ret[:keyword] = array(ret[:keyword])
        ret[:license] = array(ret[:license])
        ret
      end

      def timestamp_hash(ret)
        ret[:fetched] ||= Date.today.to_s
      end

      def extent_hash_to_bib(ret)
        return unless ret[:extent]

        ret[:extent] = array(ret[:extent])
        ret[:extent]&.each_with_index do |e, i|
          ret[:extent][i] = BibItemLocality.new(e[:type], e[:reference_from],
                                                e[:reference_to])
        end
      end

      def title_hash_to_bib(ret)
        return unless ret[:title]

        ret[:title] = array(ret[:title])
        ret[:title] = ret[:title].map do |t|
          if t.is_a?(Hash) then t
          else
            { content: t, language: "en", script: "Latn", format: "text/plain", type: "main" }
          end
        end
      end

      def language_hash_to_bib(ret)
        return unless ret[:language]

        ret[:language] = array(ret[:language])
      end

      def script_hash_to_bib(ret)
        return unless ret[:script]

        ret[:script] = array(ret[:script])
      end

      def abstract_hash_to_bib(ret)
        return unless ret[:abstract]

        ret[:abstract] = array(ret[:abstract]).map do |a|
          a.is_a?(String) ? FormattedString.new(content: a) : a
        end
      end

      def link_hash_to_bib(ret)
        return unless ret[:link]

        ret[:link] = array(ret[:link])
      end

      def place_hash_to_bib(ret)
        return unless ret[:place]

        ret[:place] = array(ret[:place]).map do |pl|
          pl.is_a?(String) ? Place.new(name: pl) : Place.new(pl)
        end
      end

      def accesslocation_hash_to_bib(ret)
        return unless ret[:accesslocation]

        ret[:accesslocation] = array(ret[:accesslocation])
      end

      def dates_hash_to_bib(ret)
        return unless ret[:date]

        ret[:date] = array(ret[:date])
        ret[:date].each_with_index do |d, i|
          # value is synonym of on: it is reserved word in YAML
          if d[:value]
            ret[:date][i][:on] ||= d[:value]
            ret[:date][i].delete(:value)
          end
        end
      end

      def docid_hash_to_bib(ret)
        return unless ret[:docid]

        ret[:docid] = array(ret[:docid])
        ret[:docid]&.each_with_index do |id, i|
          type = id[:type] || id[:id].match(/^\w+/)&.to_s
          ret[:docid][i] = DocumentIdentifier.new(id: id[:id], type: type)
        end
      end

      def version_hash_to_bib(ret)
        return unless ret[:version]

        ret[:version][:draft] = array(ret[:version][:draft])
        ret[:version] && ret[:version] = BibliographicItem::Version.new(
          ret[:version][:revision_date], ret[:version][:draft]
        )
      end

      def biblionote_hash_to_bib(ret)
        return unless ret[:biblionote]

        ret[:biblionote] = array(ret[:biblionote])
        (ret[:biblionote])&.each_with_index do |n, i|
          ret[:biblionote][i] = if n.is_a?(String)
            BiblioNote.new content: n
          else
            BiblioNote.new(
              content: n[:content], type: n[:type], language: n[:language],
              script: n[:script], format: n[:format]
            )
          end
        end
      end

      def formattedref_hash_to_bib(ret)
        ret[:formattedref] && ret[:formattedref] = formattedref(ret[:formattedref])
      end

      def docstatus_hash_to_bib(ret)
        ret[:docstatus] && ret[:docstatus] = DocumentStatus.new(
          stage: ret[:docstatus][:stage],
          substage: ret[:docstatus][:substage],
          iteration: ret[:docstatus][:iteration],
        )
      end

      def contributors_hash_to_bib(ret)
        return unless ret[:contributor]

        ret[:contributor] = array(ret[:contributor])
        ret[:contributor]&.each_with_index do |c, i|
          roles = array(ret[:contributor][i][:role]).map do |r|
            if r.is_a? Hash
              { type: r[:type], description: array(r[:description]) }
            # elsif r.is_a? Array
            #   { type: r[0], description: r.fetch(1) }
            else
              { type: r }
            end
          end
          ret[:contributor][i][:role] = roles
          ret[:contributor][i][:entity] = if c[:person]
                                            person_hash_to_bib(c[:person])
                                          else
                                            org_hash_to_bib(c[:organization])
                                          end
          ret[:contributor][i].delete(:person)
          ret[:contributor][i].delete(:organization)
        end
      end

      def org_hash_to_bib(org)
        return nil if org.nil?

        org[:identifier] = array(org[:identifier])&.map do |a|
          OrgIdentifier.new(a[:type], a[:id])
        end
        org
      end

      def person_hash_to_bib(person)
        Person.new(
          name: fullname_hash_to_bib(person),
          affiliation: affiliation_hash_to_bib(person),
          contact: contacts_hash_to_bib(person),
          identifier: person_identifiers_hash_to_bib(person),
        )
      end

      def fullname_hash_to_bib(person)
        n = person[:name]
        FullName.new(
          forename: array(n[:forename])&.map { |f| localname(f, person) },
          initial: array(n[:initial])&.map { |f| localname(f, person) },
          addition: array(n[:addition])&.map { |f| localname(f, person) },
          prefix: array(n[:prefix])&.map { |f| localname(f, person) },
          surname: localname(n[:surname], person),
          completename: localname(n[:completename], person),
        )
      end

      def person_identifiers_hash_to_bib(person)
        array(person[:identifier])&.map do |a|
          PersonIdentifier.new(a[:type], a[:id])
        end
      end

      def affiliation_hash_to_bib(person)
        return [] unless person[:affiliation]

        array(person[:affiliation]).map do |a|
          a[:description] = array(a[:description])&.map do |d|
            cnt = if d.is_a?(Hash)
                    { content: d[:content], language: d[:language],
                      script: d[:script], format: d[:format] }
                  else { content: d }
                  end
            FormattedString.new cnt
          end
          Affiliation.new(
            organization: Organization.new(org_hash_to_bib(a[:organization])),
            description: a[:description],
          )
        end
      end

      def contacts_hash_to_bib(person)
        return [] unless person[:contact]

        array(person[:contact]).map do |a|
          if a[:city] || a[:country]
            RelatonBib::Address.new(
              street: Array(a[:street]), city: a[:city], postcode: a[:postcode],
              country: a[:country], state: a[:state]
            )
          else
            RelatonBib::Contact.new(type: a[:type], value: a[:value])
          end
        end
      end

      def relations_hash_to_bib(ret)
        return unless ret[:relation]

        ret[:relation] = array(ret[:relation])
        ret[:relation]&.each_with_index do |r, i|
          relation_bibitem_hash_to_bib(ret, r, i)
          relation_biblocality_hash_to_bib(ret, r, i)
        end
      end

      # @param ret [Hash]
      # @param rel [Hash] relation
      # @param idx [Integr] index of relation
      def relation_bibitem_hash_to_bib(ret, rel, idx)
        if rel[:bibitem]
          ret[:relation][idx][:bibitem] = bib_item(hash_to_bib(rel[:bibitem], true))
        else
          warn "[relaton-bib] bibitem missing: #{rel}"
          ret[:relation][idx][:bibitem] = nil
        end
      end

      # @param item [Hash]
      # @retirn [RelatonBib::BibliographicItem]
      def bib_item(item)
        BibliographicItem.new(item)
      end

      def relation_biblocality_hash_to_bib(ret, rel, idx)
        ret[:relation][idx][:bib_locality] =
          array(rel[:bib_locality])&.map do |bl|
            BibItemLocality.new(bl[:type], bl[:reference_from],
                                bl[:reference_to])
          end
      end

      def series_hash_to_bib(ret)
        ret[:series] = array(ret[:series])&.map do |s|
          s[:formattedref] && s[:formattedref] = formattedref(s[:formattedref])
          if s[:title]
            s[:title] = { content: s[:title] } unless s.is_a?(Hash)
            s[:title] = typed_title_strig(s[:title])
          end
          s[:abbreviation] && s[:abbreviation] = localizedstring(s[:abbreviation])
          Series.new(s)
        end
      end

      # @param title [Hash]
      # @return [RelatonBib::TypedTitleString]
      def typed_title_strig(title)
        TypedTitleString.new title
      end

      def medium_hash_to_bib(ret)
        ret[:medium] = Medium.new(ret[:medium]) if ret[:medium]
      end

      def classification_hash_to_bib(ret)
        # ret[:classification] = [ret[:classification]] unless ret[:classification].is_a?(Array)
        # ret[:classification]&.each_with_index do |c, i|
        # ret[:classification][i] = RelatonBib::Classification.new(c)
        # end
        if ret[:classification]
          ret[:classification] = array(ret[:classification]).map { |cls| Classification.new cls }
        end
      end

      def validity_hash_to_bib(ret)
        return unless ret[:validity]

        ret[:validity][:begins] && b = Time.parse(ret[:validity][:begins])
        ret[:validity][:ends] && e = Time.parse(ret[:validity][:ends])
        ret[:validity][:revision] && r = Time.parse(ret[:validity][:revision])
        ret[:validity] = Validity.new(begins: b, ends: e, revision: r)
      end

      # @param ogj [Hash, Array, String]
      # @return [Hash, Array, String]
      def symbolize(obj)
        if obj.is_a? Hash
          obj.reduce({}) do |memo, (k, v)|
            memo[k.to_sym] = symbolize(v)
            memo
          end
        elsif obj.is_a? Array
          obj.reduce([]) { |memo, v| memo << symbolize(v) }
        else
          obj
        end
      end

      def array(arr)
        return [] unless arr
        return [arr] unless arr.is_a?(Array)

        arr
      end

      def localname(name, person)
        return nil if name.nil?

        lang = name[:language] if name.is_a?(Hash)
        lang ||= person[:name][:language]
        script = name[:script] if name.is_a?(Hash)
        script ||= person[:name][:script]
        if name.is_a?(Hash)
          RelatonBib::LocalizedString.new(name[:content], lang, script)
        else
          RelatonBib::LocalizedString.new(name, lang, script)
        end
      end

      def localizedstring(lst)
        if lst.is_a?(Hash)
          RelatonBib::LocalizedString.new(lst[:content], lst[:language], lst[:script])
        else
          RelatonBib::LocalizedString.new(lst)
        end
      end

      def formattedref(frf)
        if frf.is_a?(Hash)
          RelatonBib::FormattedRef.new(frf)
        else
          RelatonBib::FormattedRef.new(content: frf)
        end
      end
    end
  end
end
