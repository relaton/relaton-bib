module Relaton
  module Bib
    module Converter
      module Asciibib
        class ToAsciibib # rubocop:disable Metrics/ClassLength
          include Core::ArrayWrapper

          def initialize(item)
            @item = item
          end

          def transform
            out = "[%bibitem]\n== {blank}\n"
            out << render_id
            out << render_fetched
            out << render_titles
            out << render_type
            out << render_docidentifiers
            out << render_docnumber
            out << render_edition
            out << render_languages
            out << render_scripts
            out << render_versions
            out << render_notes
            out << render_status
            out << render_dates
            out << render_abstracts
            out << render_copyrights
            out << render_sources
            out << render_medium
            out << render_places
            out << render_extents
            out << render_size
            out << render_accesslocations
            out << render_classifications
            out << render_validity
            out << render_contributors
            out << render_relations
            out << render_series_collection
            out << render_doctype
            out << render_subdoctype
            out << render_formattedref
            out << render_keywords
            out << render_ics_collection
            out << render_structuredidentifiers
            out
          end

          private

          def render_id
            @item.id ? "id:: #{@item.id}\n" : ""
          end

          def render_fetched
            @item.fetched ? "fetched:: #{@item.fetched}\n" : ""
          end

          def render_titles
            titles = array(@item.title)
            titles.map { |t| render_title(t, "", titles.size) }.join
          end

          def render_title(title, prefix, count)
            pref = prefix.empty? ? prefix : "#{prefix}."
            out = count > 1 ? "#{pref}title::\n" : ""
            out << "#{pref}title.type:: #{title.type}\n" if title.type
            has_attrs = title.type && !title.type.empty?
            out << render_localized_string(title, "#{pref}title", 1, has_attrs)
            out
          end

          def render_type
            @item.type ? "type:: #{@item.type}\n" : ""
          end

          def render_docidentifiers
            docids = array(@item.docidentifier)
            docids.map { |di| render_docidentifier(di, "", docids.size) }.join
          end

          def render_docidentifier(di, prefix, count) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
            pref = prefix.empty? ? prefix : "#{prefix}."
            return "#{pref}docid:: #{di.content}\n" unless di.type || di.scope

            out = count > 1 ? "#{pref}docid::\n" : ""
            out << "#{pref}docidentifier.type:: #{di.type}\n" if di.type
            out << "#{pref}docidentifier.scope:: #{di.scope}\n" if di.scope
            out << "#{pref}docidentifier.primary:: #{di.primary}\n" if di.primary
            out << "#{pref}docidentifier.language:: #{di.language}\n" if di.language
            out << "#{pref}docidentifier.script:: #{di.script}\n" if di.script
            out << "#{pref}docidentifier.content:: #{di.content}\n"
            out
          end

          def render_docnumber
            @item.docnumber ? "docnumber:: #{@item.docnumber}\n" : ""
          end

          def render_edition
            return "" unless @item.edition

            ed = @item.edition
            pref = "edition"
            out = ed.content ? "#{pref}.content:: #{ed.content}\n" : ""
            out << "#{pref}.number:: #{ed.number}\n" if ed.number
            out
          end

          def render_languages
            array(@item.language).map { |l| "language:: #{l}\n" }.join
          end

          def render_scripts
            array(@item.script).map { |s| "script:: #{s}\n" }.join
          end

          def render_versions
            versions = array(@item.version)
            versions.map { |v| render_version(v, "", versions.size) }.join
          end

          def render_version(ver, prefix, count)
            pref = prefix.empty? ? prefix : "#{prefix}."
            out = count > 1 ? "#{prefix}version::\n" : ""
            out << "#{pref}version:: #{ver.content}\n" if ver.content
            out << "#{pref}version.type:: #{ver.type}\n" if ver.type
            out
          end

          def render_notes
            notes = array(@item.note)
            notes.map { |n| render_note(n, "", notes.size) }.join
          end

          def render_note(note, prefix, count) # rubocop:disable Metrics/AbcSize
            pref = prefix.empty? ? prefix : "#{prefix}."
            has_attrs = note.type && !note.type.empty?
            out = count > 1 && has_attrs ? "#{pref}biblionote::\n" : ""
            out << "#{pref}biblionote.type:: #{note.type}\n" if note.type
            out << render_localized_string(note, "#{pref}biblionote", 1, has_attrs)
            out
          end

          def render_status # rubocop:disable Metrics/AbcSize
            return "" unless @item.status

            st = @item.status
            out = "status.stage:: #{st.stage.content}\n" if st.stage
            out ||= ""
            out << "status.substage:: #{st.substage.content}\n" if st.substage
            out << "status.iteration:: #{st.iteration}\n" if st.iteration
            out
          end

          def render_dates
            dates = array(@item.date)
            dates.map { |d| render_date(d, "", dates.size) }.join
          end

          def render_date(date, prefix, count)
            pref = prefix.empty? ? prefix : "#{prefix}."
            out = count > 1 ? "#{pref}date::\n" : ""
            out << "#{pref}date.type:: #{date.type}\n"
            out << "#{pref}date.on:: #{date.at}\n" if date.at
            out << "#{pref}date.from:: #{date.from}\n" if date.from
            out << "#{pref}date.to:: #{date.to}\n" if date.to
            out
          end

          def render_abstracts
            abstracts = array(@item.abstract)
            abstracts.map { |a| render_localized_string(a, "abstract", abstracts.size) }.join
          end

          def render_copyrights
            copyrights = array(@item.copyright)
            copyrights.map { |c| render_copyright(c, "", copyrights.size) }.join
          end

          def render_copyright(cr, prefix, count) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity
            pref = prefix.empty? ? "copyright" : "#{prefix}.copyright"
            out = count > 1 ? "#{pref}::\n" : ""
            array(cr.owner).each { |ow| out << render_copyright_owner(ow, pref, array(cr.owner).size) }
            out << "#{pref}.from:: #{cr.from}\n" if cr.from
            out << "#{pref}.to:: #{cr.to}\n" if cr.to
            out << "#{pref}.scope:: #{cr.scope}\n" if cr.scope
            out
          end

          def render_copyright_owner(owner, prefix, count)
            pref = "#{prefix}.owner"
            out = count > 1 ? "#{pref}::\n" : ""
            if owner.person
              out << render_person(owner.person, pref)
            elsif owner.organization
              out << render_organization(owner.organization, pref)
            end
            out
          end

          def render_sources
            source = array(@item.source)
            source.map { |l| render_source(l, "", source.size) }.join
          end

          def render_source(source, prefix, count) # rubocop:disable Metrics/AbcSize
            pref = prefix.empty? ? "source" : "#{prefix}.link"
            out = count > 1 ? "#{pref}::\n" : ""
            out << "#{pref}.type:: #{source.type}\n" if source.type
            out << "#{pref}.content:: #{source.content}\n"
            out << "#{pref}.language:: #{source.language}\n" if source.language
            out << "#{pref}.script:: #{source.script}\n" if source.script
            out
          end

          def render_medium # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
            return "" unless @item.medium

            m = @item.medium
            out = ""
            out << "medium.content:: #{m.content}\n" if m.content
            out << "medium.genre:: #{m.genre}\n" if m.genre
            out << "medium.form:: #{m.form}\n" if m.form
            out << "medium.carrier:: #{m.carrier}\n" if m.carrier
            out << "medium.size:: #{m.size}\n" if m.size
            out << "medium.scale:: #{m.scale}\n" if m.scale
            out
          end

          def render_places
            places = array(@item.place)
            places.map { |pl| render_place(pl, "", places.size) }.join
          end

          def render_place(place, prefix, count) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
            pref = prefix.empty? ? "place" : "#{prefix}.place"
            out = count > 1 ? "#{pref}::\n" : ""
            if place.formatted_place && !place.city
              return "#{out}#{pref}.name:: #{place.formatted_place}\n"
            end

            out << "#{pref}.city:: #{place.city}\n" if place.city
            array(place.region).each { |r| out << render_region(r, "#{pref}.region", array(place.region).size) }
            array(place.country).each { |c| out << render_region(c, "#{pref}.country", array(place.country).size) }
            out
          end

          def render_region(reg, prefix, count) # rubocop:disable Metrics/AbcSize
            out = count > 1 ? "#{prefix}::\n" : ""
            out << "#{prefix}.name:: #{reg.content}\n"
            out << "#{prefix}.iso:: #{reg.iso}\n" if reg.iso
            out << "#{prefix}.recommended:: #{reg.recommended}\n" if reg.recommended
            out
          end

          def render_extents
            extents = array(@item.extent)
            extents.map { |ex| render_extent(ex, "", extents.size) }.join
          end

          def render_extent(ext, prefix, count) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity
            pref = prefix.empty? ? "extent" : "#{prefix}.extent"
            out = count > 1 ? "#{pref}::\n" : ""
            if ext.locality&.any?
              ext.locality.each { |l| out << render_locality(l, pref, ext.locality.size) }
            elsif ext.locality_stack&.any?
              ext.locality_stack.each do |ls|
                out << render_locality_stack(ls, pref, ext.locality_stack.size)
              end
            end
            out
          end

          def render_locality(loc, prefix, count)
            pref = prefix.empty? ? prefix : "#{prefix}."
            out = count > 1 ? "#{prefix}::\n" : ""
            out << "#{pref}type:: #{loc.type}\n"
            out << "#{pref}reference_from:: #{loc.reference_from}\n"
            out << "#{pref}reference_to:: #{loc.reference_to}\n" if loc.reference_to
            out
          end

          def render_locality_stack(ls, prefix, count)
            pref = "#{prefix}.locality_stack"
            out = count > 1 ? "#{pref}::\n" : ""
            ls.locality.each { |l| out << render_locality(l, pref, ls.locality.size) }
            out
          end

          def render_size # rubocop:disable Metrics/AbcSize
            return "" unless @item.size

            pref = "size"
            vals = array(@item.size.value)
            vals.map do |v|
              out = vals.size > 1 ? "#{pref}::\n" : ""
              out << "#{pref}.type:: #{v.type}\n"
              out << "#{pref}.content:: #{v.content}\n"
              out
            end.join
          end

          def render_accesslocations
            array(@item.accesslocation).map { |al| "accesslocation:: #{al}\n" }.join
          end

          def render_classifications
            cls = array(@item.classification)
            cls.map { |c| render_classification(c, "", cls.size) }.join
          end

          def render_classification(cl, prefix, count) # rubocop:disable Metrics/AbcSize
            pref = prefix.empty? ? "classification" : "#{prefix}.classification"
            out = count > 1 ? "#{pref}::\n" : ""
            out << "#{pref}.type:: #{cl.type}\n" if cl.type
            out << "#{pref}.content:: #{cl.content}\n"
            out
          end

          def render_validity # rubocop:disable Metrics/AbcSize
            return "" unless @item.validity

            v = @item.validity
            out = ""
            out << "validity.begins:: #{v.begins}\n" if v.begins
            out << "validity.ends:: #{v.ends}\n" if v.ends
            out << "validity.revision:: #{v.revision}\n" if v.revision
            out
          end

          def render_contributors
            contribs = array(@item.contributor)
            contribs.map { |c| render_contributor(c, "contributor.*", contribs.size) }.join
          end

          def render_contributor(contrib, prefix, count) # rubocop:disable Metrics/AbcSize
            pref = prefix.split(".").first
            out = count > 1 ? "#{pref}::\n" : ""
            if contrib.person
              out << render_person(contrib.person, prefix)
            elsif contrib.organization
              out << render_organization(contrib.organization, prefix)
            end
            array(contrib.role).each { |r| out << render_role(r, pref, array(contrib.role).size) }
            out
          end

          def render_role(role, prefix, count)
            pref = prefix.empty? ? prefix : "#{prefix}."
            out = count > 1 ? "#{prefix}.role::\n" : ""
            array(role.description).each do |d|
              out << render_localized_string(d, "#{pref}role.description", array(role.description).size)
            end
            out << "#{pref}role.type:: #{role.type}\n" if role.type
            out
          end

          def render_person(person, prefix) # rubocop:disable Metrics/AbcSize
            pref = prefix.sub(/\*$/, "person")
            out = render_fullname(person.name, pref)
            array(person.credential).each { |c| out << "#{pref}.credential:: #{c}\n" }
            array(person.affiliation).each { |af| out << render_affiliation(af, pref, array(person.affiliation).size) }
            array(person.identifier).each { |id| out << render_person_identifier(id, pref, array(person.identifier).size) }
            out << render_contact(person, pref)
            out
          end

          def render_fullname(name, prefix) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/MethodLength
            prf = "#{prefix}.name"
            out = ""
            out << render_localized_string(name.abbreviation, "#{prf}.abbreviation") if name.abbreviation
            array(name.forename).each { |fn| out << render_forename(fn, prefix, array(name.forename).size) }
            if name.formatted_initials
              out << render_localized_string(name.formatted_initials, "#{prefix}.given.formatted-initials")
            end
            out << render_localized_string(name.surname, "#{prf}.surname") if name.surname
            array(name.addition).each do |ad|
              out << render_localized_string(ad, "#{prf}.addition", array(name.addition).size)
            end
            array(name.prefix).each do |pr|
              out << render_localized_string(pr, "#{prf}.prefix", array(name.prefix).size)
            end
            out << render_localized_string(name.completename, "#{prf}.completename") if name.completename
            out
          end

          def render_forename(fn, prefix, count)
            render_localized_string(fn, "#{prefix}.given", count)
          end

          def render_affiliation(aff, prefix, count) # rubocop:disable Metrics/AbcSize
            pref = prefix.empty? ? prefix : "#{prefix}."
            out = count > 1 ? "#{pref}affiliation::\n" : ""
            out << render_localized_string(aff.name, "#{pref}affiliation.name") if aff.name
            array(aff.description).each do |d|
              out << render_localized_string(d, "#{pref}affiliation.description", array(aff.description).size)
            end
            out << render_organization(aff.organization, "#{pref}affiliation.*") if aff.organization
            out
          end

          def render_person_identifier(id, prefix, count)
            pref = prefix.empty? ? prefix : "#{prefix}."
            out = count > 1 ? "#{pref}identifier::\n" : ""
            out << "#{pref}identifier.type:: #{id.type}\n"
            out << "#{pref}identifier.content:: #{id.content}\n" if id.content
            out
          end

          def render_organization(org, prefix) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
            pref = prefix.sub(/\*$/, "organization")
            out = ""
            names = array(org.name)
            names.each { |n| out << render_localized_string(n, "#{pref}.name", names.size) }
            out << render_localized_string(org.abbreviation, "#{pref}.abbreviation") if org.abbreviation
            array(org.subdivision).each do |sd|
              out << "#{pref}.subdivision::" if array(org.subdivision).size > 1
              sd_names = array(sd.name)
              out << render_localized_string(sd_names.first, "#{pref}.subdivision") if sd_names.any?
            end
            ids = array(org.identifier)
            ids.each { |n| out << render_org_identifier(n, pref, ids.size) }
            out << render_contact(org, pref)
            logos = array(org.logo)
            logos.each do |l|
              out << ("#{pref}.logo::\n" if logos.size > 1).to_s
              out << render_logo(l, pref)
            end
            out
          end

          def render_org_identifier(id, prefix, count)
            pref = prefix.empty? ? prefix : "#{prefix}."
            out = count > 1 ? "#{pref}identifier::\n" : ""
            out << "#{pref}identifier.type:: #{id.type}\n"
            out << "#{pref}identifier.content:: #{id.content}\n" if id.content
            out
          end

          def render_contact(obj, prefix) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
            pref = prefix.empty? ? prefix : "#{prefix}."
            out = ""
            addrs = array(obj.address)
            addrs.each { |a| out << render_address(a, prefix, addrs.size) }
            phones = array(obj.phone)
            phones.each do |p|
              out << (phones.size > 1 ? "#{pref}contact::\n" : "")
              out << "#{pref}contact.phone:: #{p.content}\n"
              out << "#{pref}contact.type:: #{p.type}\n" if p.type
            end
            array(obj.email).each { |e| out << "#{pref}contact.email:: #{e}\n" }
            array(obj.uri).each do |u|
              out << (array(obj.uri).size > 1 ? "#{pref}contact::\n" : "")
              out << "#{pref}contact.uri:: #{u.content}\n"
              out << "#{pref}contact.type:: #{u.type}\n" if u.type
            end
            out
          end

          def render_address(addr, prefix, count) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/MethodLength
            pref = prefix.empty? ? "address" : "#{prefix}.address"
            if addr.formatted_address && !addr.city && !addr.country
              return "#{pref}.formatted_address:: #{addr.formatted_address}\n"
            end

            out = count > 1 ? "#{pref}::\n" : ""
            array(addr.street).each { |st| out << "#{pref}.street:: #{st}\n" }
            out << "#{pref}.city:: #{addr.city}\n" if addr.city
            out << "#{pref}.state:: #{addr.state}\n" if addr.state
            out << "#{pref}.country:: #{addr.country}\n" if addr.country
            out << "#{pref}.postcode:: #{addr.postcode}\n" if addr.postcode
            out
          end

          def render_logo(logo, prefix)
            render_image(logo.image, "#{prefix}.logo") if logo.image
          end

          def render_image(img, prefix) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/MethodLength
            pref = "#{prefix}.image."
            out = ""
            out << "#{pref}id:: #{img.id}\n" if img.id
            out << "#{pref}src:: #{img.src}\n"
            out << "#{pref}mimetype:: #{img.mimetype}\n"
            out << "#{pref}filename:: #{img.filename}\n" if img.filename
            out << "#{pref}width:: #{img.width}\n" if img.width
            out << "#{pref}height:: #{img.height}\n" if img.height
            out << "#{pref}alt:: #{img.alt}\n" if img.alt
            out << "#{pref}title:: #{img.title}\n" if img.title
            out << "#{pref}longdesc:: #{img.longdesc}\n" if img.longdesc
            out
          end

          def render_relations
            rels = array(@item.relation)
            return "" unless rels.any?

            pref = "relation"
            rels.map do |r|
              out = rels.size > 1 ? "#{pref}::\n" : ""
              out << render_relation(r, pref)
              out
            end.join
          end

          def render_relation(rel, prefix) # rubocop:disable Metrics/AbcSize
            pref = prefix.empty? ? prefix : "#{prefix}."
            out = "#{prefix}.type:: #{rel.type}\n"
            out << render_localized_string(rel.description, "#{pref}desctiption") if rel.description
            out << render_bibitem(rel.bibitem, "#{pref}bibitem") if rel.bibitem
            out
          end

          def render_bibitem(item, prefix) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
            pref = prefix.empty? ? prefix : "#{prefix}."
            out = ""
            out << "#{pref}formattedref:: #{item.formattedref.content}\n" if item.formattedref
            array(item.title).each { |t| out << render_title(t, prefix, array(item.title).size) }
            array(item.docidentifier).each do |di|
              out << render_docidentifier(di, prefix, array(item.docidentifier).size)
            end
            out << "#{pref}type:: #{item.type}\n" if item.type
            array(item.date).each { |d| out << render_date(d, prefix, array(item.date).size) }
            array(item.contributor).each do |c|
              out << render_contributor(c, "#{prefix}.contributor.*", array(item.contributor).size)
            end
            out << render_edition_nested(item.edition, prefix) if item.edition
            array(item.language).each { |l| out << "#{pref}language:: #{l}\n" }
            array(item.script).each { |s| out << "#{pref}script:: #{s}\n" }
            array(item.abstract).each do |a|
              out << render_localized_string(a, "#{pref}abstract", array(item.abstract).size)
            end
            array(item.source).each { |l| out << render_source(l, prefix, array(item.source).size) }
            out
          end

          def render_edition_nested(edition, prefix)
            pref = prefix.empty? ? "edition" : "#{prefix}.edition"
            out = "#{pref}.content:: #{edition.content}\n"
            out << "#{pref}.number:: #{edition.number}\n" if edition.number
            out
          end

          def render_series_collection
            series = array(@item.series)
            series.map { |s| render_series(s, "", series.size) }.join
          end

          def render_series(ser, prefix, count) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
            pref = prefix.empty? ? "series" : "#{prefix}.series"
            out = count > 1 ? "#{pref}::\n" : ""
            out << "#{pref}.type:: #{ser.type}\n" if ser.type
            out << "#{pref}.formattedref:: #{ser.formattedref.content}\n" if ser.formattedref
            array(ser.title).each { |t| out << render_title(t, pref, 1) }
            out << render_series_place(ser.place, pref) if ser.place
            out << "#{pref}.organization:: #{ser.organization}\n" if ser.organization
            out << render_localized_string(ser.abbreviation, "#{pref}.abbreviation") if ser.abbreviation
            out << "#{pref}.from:: #{ser.from}\n" if ser.from
            out << "#{pref}.to:: #{ser.to}\n" if ser.to
            out << "#{pref}.number:: #{ser.number}\n" if ser.number
            out << "#{pref}.partnumber:: #{ser.partnumber}\n" if ser.partnumber
            out << "#{pref}.run:: #{ser.run}\n" if ser.run
            out
          end

          def render_series_place(place, prefix)
            render_place(place, prefix, 1)
          end

          def render_doctype
            return "" unless @item.ext&.doctype

            dt = @item.ext.doctype
            out = "doctype.content:: #{dt.content}\n"
            out << "doctype.abbreviation:: #{dt.abbreviation}\n" if dt.abbreviation
            out
          end

          def render_subdoctype
            return "" unless @item.ext&.subdoctype

            "subdoctype:: #{@item.ext.subdoctype}\n"
          end

          def render_formattedref
            @item.formattedref ? "formattedref:: #{@item.formattedref.content}\n" : ""
          end

          def render_keywords
            kws = array(@item.keyword)
            kws.map { |kw| render_keyword(kw, "keyword", kws.size) }.join
          end

          def render_keyword(kw, prefix, count)
            if kw.vocab
              render_localized_string(kw.vocab, prefix, count)
            else
              array(kw.taxon).map { |t| render_localized_string(t, prefix, count) }.join
            end
          end

          def render_ics_collection
            return "" unless @item.ext

            icss = array(@item.ext.ics)
            icss.map { |i| render_ics(i, "", icss.size) }.join
          end

          def render_ics(ics, prefix, count)
            pref = prefix.empty? ? "ics" : "#{prefix}.ics"
            out = count > 1 ? "#{pref}::\n" : ""
            out << "#{pref}.code:: #{ics.code}\n"
            out << "#{pref}.text:: #{ics.text}\n" if ics.text
            out
          end

          def render_structuredidentifiers
            return "" unless @item.ext

            sids = array(@item.ext.structuredidentifier)
            pref = "structured_identifier"
            sids.map do |si|
              out = sids.size > 1 ? "#{pref}::\n" : ""
              out << render_structured_identifier(si, pref)
              out
            end.join
          end

          def render_structured_identifier(si, prefix) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/MethodLength
            out = "#{prefix}.docnumber:: #{si.docnumber}\n"
            array(si.agency).each { |a| out << "#{prefix}.agency:: #{a}\n" }
            out << "#{prefix}.type:: #{si.type}\n" if si.type
            out << "#{prefix}.class:: #{si.klass}\n" if si.klass
            out << "#{prefix}.partnumber:: #{si.partnumber}\n" if si.partnumber
            out << "#{prefix}.edition:: #{si.edition}\n" if si.edition
            out << "#{prefix}.version:: #{si.version}\n" if si.version
            out << "#{prefix}.supplementtype:: #{si.supplementtype}\n" if si.supplementtype
            out << "#{prefix}.supplementnumber:: #{si.supplementnumber}\n" if si.supplementnumber
            out << "#{prefix}.language:: #{si.language}\n" if si.language
            out << "#{prefix}.year:: #{si.year}\n" if si.year
            out
          end

          def render_localized_string(ls, prefix, count = 1, has_attrs = false) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/MethodLength
            return "" unless ls

            pref = prefix.empty? ? prefix : "#{prefix}."
            unless ls.language || ls.script || has_attrs
              return "#{prefix}:: #{ls.content}\n"
            end

            out = count > 1 ? "#{prefix}::\n" : ""
            out << "#{pref}content:: #{ls.content}\n" if ls.content
            out << "#{pref}language:: #{ls.language}\n" if ls.language
            out << "#{pref}script:: #{ls.script}\n" if ls.script
            out
          end
        end
      end
    end
  end
end
