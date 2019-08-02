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
          t.is_a?(Hash) ? t : { content: t, language: "en", script: "Latn", 
                                format: "text/plain", type: "main" }
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
        ret[:abstract] = array(ret[:abstract])
      end

      def link_hash_to_bib(ret)
        return unless ret[:link]
        ret[:link] = array(ret[:link])
      end

      def place_hash_to_bib(ret)
        return unless ret[:place]
        ret[:place] = array(ret[:place])
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
          ret[:docid][i] = DocumentIdentifier.new(id: id[:id], type: id[:type])
        end
      end

      def version_hash_to_bib(ret)
        return unless ret[:version]
        ret[:version][:draft] = array(ret[:version][:draft])
        ret[:version] and ret[:version] = BibliographicItem::Version.new(
            ret[:version][:revision_date], ret[:version][:draft])
      end

      def biblionote_hash_to_bib(ret)
        return unless ret[:biblionote]
        ret[:biblionote] = array(ret[:biblionote])
        (ret[:biblionote])&.each_with_index do |n, i|
          ret[:biblionote][i] =
            BiblioNote.new(content: n[:content], type: n[:type], 
                          language: n[:language], 
                          script: n[:script], format: n[:format])
        end
      end

      def formattedref_hash_to_bib(ret)
        ret[:formattedref] and ret[:formattedref] =
          formattedref(ret[:formattedref])
      end

      def docstatus_hash_to_bib(ret)
        ret[:docstatus] and ret[:docstatus] =
          DocumentStatus.new(stage: ret[:docstatus][:stage],
                            substage: ret[:docstatus][:substage],
                            iteration: ret[:docstatus][:iteration])
      end

      def contributors_hash_to_bib(ret)
        return unless ret[:contributor]
        ret[:contributor] = array(ret[:contributor])
        ret[:contributor]&.each_with_index do |c, i|
          roles = array(ret[:contributor][i][:role]).map do |r|
            if r.is_a? Array
              { type: r[0], description: r.fetch(1) }
            else
              { type: r }
            end
          end
          ret[:contributor][i][:role] = roles
          ret[:contributor][i][:entity] = c[:person] ?
            person_hash_to_bib(c[:person]) : org_hash_to_bib(c[:organization])
          ret[:contributor][i].delete(:person)
          ret[:contributor][i].delete(:organization)
        end
      end

      def org_hash_to_bib(c)
        return nil if c.nil?
        c[:identifier] = array(c[:identifier])&.map do |a|
          OrgIdentifier.new(a[:type], a[:id])
        end
        c
      end

      def person_hash_to_bib(c)
        Person.new(
          name: fullname_hash_to_bib(c),
          affiliation: affiliation_hash_to_bib(c),
          contact: contacts_hash_to_bib(c),
          identifier: person_identifiers_hash_to_bib(c),
        )
      end

      def fullname_hash_to_bib(c)
        n = c[:name]
        FullName.new(
          forename: array(n[:forename])&.map { |f| localname(f, c) },
          initial: array(n[:initial])&.map { |f| localname(f, c) },
          addition: array(n[:addition])&.map { |f| localname(f, c) },
          prefix: array(n[:prefix])&.map { |f| localname(f, c) },
          surname: localname(n[:surname], c),
          completename: localname(n[:completename], c),
        )
      end

      def person_identifiers_hash_to_bib(c)
        array(c[:identifier])&.map do |a|
          PersonIdentifier.new(a[:type], a[:id])
        end
      end

      def affiliation_hash_to_bib(c)
        return [] unless c[:affiliation]
        array(c[:affiliation]).map do |a|
          a[:description] = array(a[:description])&.map do |d|
            FormattedString.new(
              d.is_a?(Hash) ?
              { content: d[:content], language: d[:language],
                script: d[:script], format: d[:format] } : 
            { content: d })
          end
          Affilation.new(
            Organization.new(org_hash_to_bib(a[:organization])), a[:description])
        end
      end

      def contacts_hash_to_bib(c)
        return [] unless c[:contact]
        array(c[:contact]).map do |a|
          (a[:city] || a[:country]) ?
            RelatonBib::Address.new(
              street: Array(a[:street]), city: a[:city], postcode: a[:postcode],
              country: a[:country], state: a[:state]) :
          RelatonBib::Contact.new(type: a[:type], value: a[:value])
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

      def relation_bibitem_hash_to_bib(ret, r, i)
        if r[:bibitem] then ret[:relation][i][:bibitem] =
            BibliographicItem.new(hash_to_bib(r[:bibitem], true))
        else
          warn "bibitem missing: #{r}"
          ret[:relation][i][:bibitem] = nil
        end
      end

      def relation_biblocality_hash_to_bib(ret, r, i)
        ret[:relation][i][:bib_locality] =
          array(r[:bib_locality])&.map do |bl|
            BibItemLocality.new(bl[:type], bl[:reference_from],
                                bl[:reference_to])
          end
      end

      def series_hash_to_bib(ret)
        array(ret[:series])&.each_with_index do |s, i|
          s[:formattedref] and s[:formattedref] = formattedref(s[:formattedref])
          if s[:title]
            s[:title] = { content: s[:title] } unless s.is_a?(Hash)
            s[:title] = TypedTitleString.new(s[:title])
          end
          s[:abbreviation] and
            s[:abbreviation] = localizedstring(s[:abbreviation])
          ret[:series][i] = Series.new(s)
        end
      end

      def medium_hash_to_bib(ret)
        ret[:medium] and ret[:medium] = Medium.new(ret[:medium])
      end

      def classification_hash_to_bib(ret)
        #ret[:classification] = [ret[:classification]] unless ret[:classification].is_a?(Array)
        #ret[:classification]&.each_with_index do |c, i|
        #ret[:classification][i] = RelatonBib::Classification.new(c)
        #end
        ret[:classification] and
          ret[:classification] = Classification.new(ret[:classification])
      end

      def validity_hash_to_bib(ret)
        return unless ret[:validity]
        ret[:validity][:begins] and b = Time.parse(ret[:validity][:begins])
        ret[:validity][:ends] and e = Time.parse(ret[:validity][:ends])
        ret[:validity][:revision] and r = Time.parse(ret[:validity][:revision])
        ret[:validity] = Validity.new(begins: b, ends: e, revision: r)
      end

      def symbolize(obj)
        obj.is_a? Hash and
          return obj.inject({}){|memo,(k,v)| memo[k.to_sym] =  symbolize(v); memo}
        obj.is_a? Array and
          return obj.inject([]){|memo,v    | memo           << symbolize(v); memo}
        return obj
      end

      def array(a)
        return [] unless a
        return [a] unless a.is_a?(Array)
        a
      end

      def localname(f, c)
        return nil if f.nil?
        f.is_a?(Hash) and lang = f[:language] 
        lang ||= c[:name][:language] 
        f.is_a?(Hash) and script = f[:script] 
        script ||= c[:name][:script]
        f.is_a?(Hash) ?
          RelatonBib::LocalizedString.new(f[:content], lang, script) :
          RelatonBib::LocalizedString.new(f, lang, script)
      end

      def localizedstring(f)
        f.is_a?(Hash) ?
          RelatonBib::LocalizedString.new(f[:content], f[:language], f[:script]) :
          RelatonBib::LocalizedString.new(f)
      end

      def formattedref(f)
        f.is_a?(Hash) ? RelatonBib::FormattedRef.new(f) :
          RelatonBib::FormattedRef.new(content: f)
      end
    end
  end
end
