module Relaton
  module Bib
    module Converter
      module BibXml
        class ToRfcxml
          def initialize(item, include_keywords: true)
            @item = item
            @include_keywords = include_keywords
          end

          def transform
            model = ::Rfcxml::V3::Reference.new
            model.anchor = create_anchor
            model.target = create_target
            model.front = create_front
            model.format = create_format
            model
          end

          private

          def create_anchor
            docid = @item.docidentifier.detect(&:primary) ||
              @item.docidentifier[0]
            return unless docid

            docid.content.to_s.sub(/^(RFC|BCP|FYI|STD) /, '\1').sub(/^\w+\./,
                                                                    "")
          end

          def create_target
            target = @item.source.detect { |l| l.type.casecmp("src").zero? } ||
              @item.source.detect { |l| l.type.casecmp("doi").zero? }
            return unless target

            target.content.to_s
          end

          def create_front # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
            front = ::Rfcxml::V3::Front.new
            front.title = Rfcxml::V3::Title.new(content: @item.title[0].content)
            front.series_info = create_seriesinfo
            front.author = create_authors
            front.date = create_date
            front.workgroup = create_workgroup
            front.keyword = create_keyword if @include_keywords
            front.abstract = create_abstract
            front
          end

          def create_seriesinfo
            docidentifier_to_seriesinfo + series_to_seriesinfo
          end

          def docidentifier_to_seriesinfo
            @item.docidentifier.each_with_object([]) do |di, si|
              if di.type == "DOI" && di.scope != "trademark"
                si << Rfcxml::V3::SeriesInfo.new(name: di.type,
                                                 value: di.content)
              end
            end
          end

          def series_to_seriesinfo # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity
            @item.series.select do |s|
              s.title.reject { |t| t.content == "DOI" }.any?
            end.uniq do |s|
              s.title.find { |t| t.content != "DOI" }.content
            end.each_with_object([]) do |s, si|
              title = s.title.find { |t| t.content != "DOI" }
              si << Rfcxml::V3::SeriesInfo.new(name: title.content,
                                               value: s.number)
            end
          end

          def create_authors # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
            @item.contributor.map do |contrib|
              role = "editor" if contrib.role.detect { |r| r.type == "editor" }
              Rfcxml::V3::Author.new(
                role: role,
                initials: person_initials(contrib.person),
                surname: person_surname(contrib.person),
                fullname: person_fullname(contrib.person),
                organization: create_organization(contrib),
                address: create_address(contrib),
              )
            end
          end

          def person_fullname(person) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
            return unless person

            if person.name.completename
              person.name.completename.content
            elsif person.name.forename.any?
              parts = person.name.forename.map { |n| n.content || n.initial }
              parts << person.name.surname.content if person.name.surname
              parts.join(" ")
            end
          end

          def person_initials(person) # rubocop:disable Metrics/AbcSize
            return unless person

            if person.name.formatted_initials
              person.name.formatted_initials.content
            elsif person.name.forename.any?
              person.name.forename.map do |f|
                "#{f.initial || f.content[0]}."
              end.join " "
            end
          end

          def person_surname(person)
            return unless person

            person.name.surname&.content
          end

          def create_organization(contrib) # rubocop:disable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity,Metrics/AbcSize
            org = contrib_org(contrib)
            return unless org

            abbrev = org.abbreviation&.content
            orgname = resolve_orgname(org, abbrev)
            Rfcxml::V3::Organization.new(
              content: orgname, abbrev: abbrev,
            )
          end

          def contrib_org(contrib)
            contrib.organization ||
              (contrib.person && contrib.person.affiliation[0]&.organization)
          end

          def resolve_orgname(org, abbrev)
            orgname = org.name&.first&.content
            if ORGNAMES.key?(abbrev) then abbrev
            else ORGNAMES.key(orgname) || orgname || abbrev
            end
          end

          def create_address(contrib) # rubocop:disable Metrics/AbcSize
            entity = contrib.person || contrib.organization
            return unless entity.address.any? || entity.phone.any? ||
              entity.email.any? || entity.uri.any?

            Rfcxml::V3::Address.new(
              postal: address_postal(entity),
              phone: address_phone(entity),
              email: address_email(entity),
              uri: address_uri(entity),
            )
          end

          def address_postal(entity)
            args = address_postal_args(entity)
            return unless args.values.any?(&:any?)

            Rfcxml::V3::Postal.new(**args)
          end

          def address_postal_args(entity)
            {
              city: address_cities(entity),
              code: address_postcodes(entity),
              country: address_countries(entity),
              region: address_states(entity),
              street: address_streets(entity),
              postal_line: address_postal_lines(entity),
            }
          end

          def address_cities(entity)
            entity.address.each_with_object([]) do |addr, cities|
              next unless addr.city

              cities << Rfcxml::V3::City.new(content: addr.city)
            end
          end

          def address_postcodes(entity)
            entity.address.each_with_object([]) do |addr, codes|
              next unless addr.postcode

              codes << Rfcxml::V3::Code.new(content: addr.postcode)
            end
          end

          def address_countries(entity)
            entity.address.each_with_object([]) do |addr, countries|
              next unless addr.country

              countries << Rfcxml::V3::Country.new(content: addr.country)
            end
          end

          def address_states(entity)
            entity.address.each_with_object([]) do |addr, states|
              next unless addr.state

              states << Rfcxml::V3::Region.new(content: addr.state)
            end
          end

          def address_streets(entity)
            entity.address.each_with_object([]) do |address, streets|
              address.street.each do |street|
                streets << Rfcxml::V3::Street.new(content: street)
              end
            end
          end

          def address_postal_lines(entity)
            entity.address.each_with_object([]) do |addr, plines|
              next unless addr.formatted_address

              plines << Rfcxml::V3::PostalLine.new(
                content: addr.formatted_address,
              )
            end
          end

          def address_phone(entity)
            return unless entity.phone.any?

            Rfcxml::V3::Phone.new(content: entity.phone[0].content)
          end

          def address_email(entity)
            entity.email.each_with_object([]) do |email, emails|
              emails << Rfcxml::V3::Email.new(content: email)
            end
          end

          def address_uri(entity)
            return unless entity.uri.any?

            Rfcxml::V3::Uri.new(content: entity.uri[0].content)
          end

          def create_date # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity
            pub_date = @item.date.detect { |d| d.type == "published" }
            return unless pub_date

            args = {}
            [pub_date.at, pub_date.from, pub_date.to].compact.each do |d|
              year, month, day = d.split("-")
              args[:year] ||= year
              args[:month] ||= ::Date::MONTHNAMES[month.to_i]
              args[:day] ||= day
            end
            Rfcxml::V3::Date.new(**args)
          end

          def create_workgroup
            @item.ext&.editorialgroup&.technical_committee&.each do |tc|
              Rfcxml::V3::Workgroup.new content: tc.content
            end
          end

          def create_keyword
            @item.keyword.inject([]) do |a, k|
              a + k.taxon.map { |t| Rfcxml::V3::Keyword.new content: t.content }
            end
          end

          def create_abstract
            return unless @item.abstract.any?

            content = @item.abstract[0].content
            Rfcxml::V3::Abstract.new(
              t: [Rfcxml::V3::Text.new(content: content)],
            )
          end

          FORMAT_TYPES = %w[TXT HTML PDF XML DOC].freeze

          def create_format # rubocop:disable Metrics/AbcSize
            @item.source.each_with_object([]) do |l, a|
              next unless FORMAT_TYPES.any? { |ft| l.type.casecmp(ft).zero? }

              a << Rfcxml::V3::Format.new(
                type: l.type, target: l.content,
              )
            end
          end
        end
      end
    end
  end
end
