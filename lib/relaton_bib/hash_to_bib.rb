module RelatonBib
  class << self
    def hash_to_bib(**args)
      ret = Marshal.load(Marshal.dump(args)) # deep copy
      docid_hash_to_bib(ret)
      version_hash_to_bib(ret)
      biblionote_hash_to_bib(ret)
      formattedref_hash_to_bib(ret)
      docstatus_hash_to_bib(ret)
      contributors_hash_to_bib(ret)
      relations_hash_to_bib(ret)
      series_hash_to_bib(ret)
      medium_hash_to_bib(ret)
      extent_hash_to_bib(ret)
      classification_hash_to_bib(ret)
      validity_hash_to_bib(ret)
      ret
    end

    def docid_hash_to_bib(ret)
      ret[:docid]&.each_with_index do |id, i|
        ret[:docid][i] = RelatonBib::DocumentIdentifier.new(id: id[:id],
                                                            type: id[:type])
      end
    end

    def version_hash_to_bib(ret)
      ret[:version] and ret[:version] =
        RelatonBib::BibliographicItem::Version.new(
          ret[:version][:revision_date], ret[:version][:draft])
    end

    def biblionote_hash_to_bib(ret)
      ret[:biblionote]&.each_with_index do |n, i|
        ret[:biblionote][i] =
          RelatonBib::BiblioNote.new(content: n[:content], type: n[:type],
                                     language: n[:language], script: n[:script],
                                     format: n[:format])
      end
    end

    def formattedref_hash_to_bib(ret)
      ret[:formattedref] and ret[:formattedref] =
        formattedref(ret[:formattedref])
    end

    def docstatus_hash_to_bib(ret)
      ret[:docstatus] and ret[:docstatus] =
        RelatonBib::DocumentStatus.new(stage: ret[:docstatus][:stage],
                                       substage: ret[:docstatus][:substage],
                                       iteration: ret[:docstatus][:iteration])
    end

    def is_person_hash(c)
      c.is_a?(Hash) and c[:entity].is_a?(Hash) and
        c[:entity][:name].is_a?(Hash) and
        (c.dig(:entity, :name, :completename) ||
         c.dig(:entity, :name, :surname))
    end

    def contributors_hash_to_bib(ret)
      ret[:contributors]&.each_with_index do |c, i|
        if is_person_hash(c)
          ret[:contributors][i][:entity] = person_hash_to_bib(c[:entity])
        else
          ret[:contributors][i][:entity] = org_hash_to_bib(c[:entity])
        end
      end
    end

    def org_hash_to_bib(c)
      return nil if c.nil?
      c[:identifiers] = Array(c[:identifiers]).map do |a|
        RelatonBib::OrgIdentifier.new(a[:type], a[:id])
      end
      c
    end

    def person_hash_to_bib(c)
      RelatonBib::Person.new(
        name: fullname_hash_to_bib(c),
        affiliation: affiliation_hash_to_bib(c),
        contacts: contacts_hash_to_bib(c),
        identifiers: person_identifiers_hash_to_bib(c),
      )
    end

    def fullname_hash_to_bib(c)
      n = c[:name]
      RelatonBib::FullName.new(
        forenames: Array(n[:forenames]).map { |f| localname(f, c) },
        initials: Array(n[:initials]).map { |f| localname(f, c) },
        additions: Array(n[:additions]).map { |f| localname(f, c) },
        prefix: Array(n[:prefix]).map { |f| localname(f, c) },
        surname: localname(n[:surname], c),
        completename: localname(n[:completename], c),
      )
    end

    def affiliation_hash_to_bib(c)
      Array(c[:affiliation]).map do |a|
        a[:description] = Array(a[:description]).map do |d|
          RelatonBib::FormattedString.new(d.nil? ? { content: nil } :
            {content: d[:content], 
             language: d[:language], 
             script: d[:language], 
             format: d[:format]})
        end
        RelatonBib::Affilation.new(
          RelatonBib::Organization.new(org_hash_to_bib(a[:organization])),
          a[:description])
      end
    end

    def contacts_hash_to_bib(c)
      Array(c[:contacts]).map do |a|
        (a[:city] || a[:country]) ?
          RelatonBib::Address.new(
            street: Array(a[:street]), city: a[:city], postcode: a[:postcode],
            country: a[:country], state: a[:state]) :
        RelatonBib::Contact.new(type: a[:type], value: a[:value])
      end
    end

    def person_identifiers_hash_to_bib(c)
      Array(c[:identifiers]).map do |a|
        RelatonBib::PersonIdentifier.new(a[:type], a[:id])
      end
    end

    def relations_hash_to_bib(ret)
      ret[:relations]&.each_with_index do |r, i|
        ret[:relations][i][:bibitem] =
          RelatonBib::BibliographicItem.new(
            hash_to_bib(ret[:relations][i][:bibitem]))
        ret[:relations][i][:bib_locality] =
          Array(ret[:relations][i][:bib_locality]).map do |bl|
            RelatonBib::BibItemLocality.new(
              bl[:type], bl[:reference_from], bl[:reference_to])
          end
      end
    end

    def series_hash_to_bib(ret)
      ret[:series]&.each_with_index do |s, i|
        s[:formattedref] and s[:formattedref] = formattedref(s[:formattedref])
        if s[:title]
          s[:title] = {content: s[:title]} unless s.is_a?(Hash)
          s[:title] = RelatonBib::TypedTitleString.new(s[:title])
        end
        s[:abbreviation] and s[:abbreviation] = localizedstring(s[:abbreviation])
        ret[:series][i] = RelatonBib::Series.new(s)
      end
    end

    def medium_hash_to_bib(ret)
      ret[:medium] and ret[:medium] = RelatonBib::Medium.new(ret[:medium])
    end

    def extent_hash_to_bib(ret)
      ret[:extent]&.each_with_index do |e, i|
        ret[:extent][i] = RelatonBib::BibItemLocality.new(e[:type],
                                                          e[:reference_from],
                                                          e[:reference_to])
      end
    end

    def classification_hash_to_bib(ret)
      #ret[:classification]&.each_with_index do |c, i|
      #ret[:classification][i] = RelatonBib::Classification.new(c)
      #end
      ret[:classification] and 
        ret[:classification] = RelatonBib::Classification.new(ret[:classification])
    end

    def validity_hash_to_bib(ret)
      ret[:validity] and ret[:validity] =
        RelatonBib::Validity.new(begins: Time.parse(ret[:validity][:begins]),
                                 ends: Time.parse(ret[:validity][:ends]),
                                 revision: Time.parse(ret[:validity][:revision]))
    end

    def localname(f, c)
      return nil if f.nil?
      f.is_a?(Hash) and lang = f[:language] 
      lang ||= c[:name][:language] 
      f.is_a?(Hash) and script = f[:script] 
      script ||= c[:name][:script]
      f.is_a?(Hash) ? RelatonBib::LocalizedString.new(f[:content], lang, script) :
        RelatonBib::LocalizedString.new(f, lang, script)
    end

    def localizedstring(f)
      f.is_a?(Hash) ? RelatonBib::LocalizedString.new(f[:content], f[:language], f[:script]) :
        RelatonBib::LocalizedString.new(f)
    end

    def formattedref(f)
      f.is_a?(Hash) ? RelatonBib::FormattedRef.new(f) :
        RelatonBib::FormattedRef.new(content: f)
    end
  end
end
