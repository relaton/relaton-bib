module Relaton
  module Bib
    module Converter
      module BibXml
        #
        # Strict RFC 7991 (xml2rfc v3) flavour of {ToRfcxml}.
        #
        # It differs from the BibXML output its parent produces in four ways:
        #
        # * the deprecated `<format>` element is never emitted;
        # * identifiers of documents published outside the IETF go into
        #   `<refcontent>` rather than being forced into `<seriesInfo>`
        #   (RFC 7991 2.39), as do series that carry no number;
        # * `<stream>` and the `ascii*` attributes are populated;
        # * `<front>` is filled out enough to satisfy the v3 grammar, which
        #   requires a title and at least one author.
        #
        class ToRfcxmlV3 < ToRfcxml
          # Organizations whose documents are "home" standards: their
          # identifiers are expressible as <seriesInfo>.
          HOME_ORGS = [
            "IETF", "Internet Engineering Task Force", "RFC Publisher"
          ].freeze

          # Identifier types that are already emitted as <seriesInfo> by the
          # parent, or that never belong in one.
          NON_AUTHORITATIVE_TYPES = %w[DOI URI].freeze

          # Identifiers metanorma-ietf drops as internal bookkeeping.
          IGNORED_ID_RE = /\A(rfc-anchor|Internet-Draft)/

          # Series that name the document itself; handled as identifiers.
          SUBSERIES = %w[BCP STD].freeze

          HOME_ID_RE = /\A(?<name>RFC|BCP|STD|FYI)\s*(?<value>\d+)\z/i
          # xml2rfc only resolves a draft reference when seriesInfo carries the
          # full draft name, so keep `draft-…` intact. The `I-D.` anchor form
          # is a citation label, not the identifier (metanorma-ietf#283).
          DRAFT_ID_RE = /\A(?<value>draft-\S+)\z/i
          DRAFT_ANCHOR_RE = /\AI-D[.\s]\s*\S+\z/i

          # Identifier types that duplicate a human-readable identifier or are
          # bookkeeping rather than citation content (metanorma-ietf#301).
          EXCLUDED_ID_TYPES = %w[URN].freeze

          # Title parts joined when relaton supplies no composite title.
          TITLE_PARTS = %w[title-intro title-main title-part].freeze

          # Roles that may stand in for an author when the item names none,
          # mirroring the released renderer's `creatornames_roles_allowed`.
          FALLBACK_ROLES = %w[performer adapter translator publisher
                              distributor authorizer].freeze

          # The values RFC XML v3 allows on <stream>; "editorial" was added by
          # RFC 9280. Keyed by the spellings the RFC Editor and relaton-ietf
          # use, so "Independent Submission" is not silently thrown away.
          STREAMS = {
            "ietf" => "IETF", "iab" => "IAB", "irtf" => "IRTF",
            "independent" => "independent",
            "independent submission" => "independent",
            "independent submission stream" => "independent",
            "editorial" => "editorial", "rfc editor" => "editorial",
            "rfc-editor" => "editorial"
          }.freeze

          # Latin letters with no NFKD decomposition, which would otherwise be
          # dropped outright ("Sørensen" -> "Srensen").
          TRANSLITERATIONS = {
            "æ" => "ae", "Æ" => "AE", "œ" => "oe", "Œ" => "OE",
            "ø" => "o", "Ø" => "O", "ß" => "ss", "ẞ" => "SS",
            "đ" => "d", "Đ" => "D", "ð" => "d", "Ð" => "D",
            "þ" => "th", "Þ" => "Th", "ł" => "l", "Ł" => "L",
            "ħ" => "h", "Ħ" => "H", "ŋ" => "ng", "Ŋ" => "NG",
            "ŧ" => "t", "Ŧ" => "T", "ı" => "i", "ĸ" => "k"
          }.freeze

          def transform
            model = ::Rfcxml::V3::Reference.new
            model.anchor = create_anchor
            model.target = create_target
            model.stream = create_stream
            model.front = create_front
            model.refcontent = create_refcontent
            model
          end

          private

          # The released IETF renderer takes an HTML-typed uri as the reference
          # target when there is no src (isodoc/ietf/references.rb), and the
          # transformer does the same; match it here.
          def target_types = %w[src HTML doi]

          # anchor is mandatory in v3 and is an XML identifier, so fall back
          # through every source the item has and never leave whitespace in it.
          def create_anchor
            sanitize_anchor(@anchor || @item.docnumber || derive_anchor ||
                            @item.id)
          end

          def sanitize_anchor(anchor)
            return nil if anchor.nil?

            anchor.to_s.strip.gsub(/\s+/, ".")
          end

          # <front> needs a title and at least one author to be valid v3.
          def create_front
            front = super
            front.title = compound_title || formattedref_title
            front.author = [unknown_author] if Array(front.author).empty?
            front
          end

          # The base emitter takes title[0], which on a multipart standard is
          # the intro alone ("IT Security techniques"). A citation needs the
          # whole compound, so prefer the composite title relaton builds, then
          # the intro-main-part join, then whatever is first.
          def compound_title
            content = composite_title || joined_title ||
              @item.title.first&.content
            return nil if content.nil?

            ::Rfcxml::V3::Title.new(content: plain_text(content))
          end

          def composite_title
            @item.title.find { |t| t.type == "main" }&.content
          end

          def joined_title
            parts = TITLE_PARTS.filter_map do |type|
              @item.title.find { |t| t.type == type }&.content
            end
            parts.empty? ? nil : parts.join(" - ")
          end

          def formattedref_title
            content = @item.formattedref&.content or return nil

            ::Rfcxml::V3::Title.new(content: plain_text(content))
          end

          # v3 <title> is text-only, so inline markup a formattedref or title
          # carries has to be flattened rather than escaped into the output.
          def plain_text(content)
            text = content.to_s
            return text unless text.include?("<")

            Nokogiri::XML.fragment(text).text.squeeze(" ").strip
          end

          def unknown_author
            ::Rfcxml::V3::Author.new(surname: "Unknown")
          end

          # One <seriesInfo> per (name, value): the same identifier can arrive
          # from a docidentifier and a series, or from two docidentifiers that
          # spell it differently ("RFC 2119" and "RFC2119").
          def create_seriesinfo
            (docidentifier_to_seriesinfo + series_to_seriesinfo +
              identifier_to_seriesinfo).uniq { |si| [si.name, si.value] }
          end

          # Only series that carry a number can become <seriesInfo>; the rest
          # are rendered as <refcontent>.
          def series_to_seriesinfo
            numbered_series.map do |ser|
              ::Rfcxml::V3::SeriesInfo.new(name: series_title(ser).content,
                                           value: ser.number)
            end
          end

          def numbered_series
            renderable_series.select(&:number)
          end

          # Series that are neither the stream marker nor a restatement of
          # something already rendered from the document's identifiers. Only
          # names actually emitted elsewhere are dropped: a series such as
          # Internet-Draft still carries its number when no docidentifier
          # supplies one.
          def renderable_series
            @item.series.reject { |ser| skip_series?(ser) }
              .uniq { |ser| series_title(ser).content }
          end

          def skip_series?(ser)
            return true if ser.type == "stream"

            title = series_title(ser)
            title.nil? || title.content.to_s == "DOI" ||
              identifier_series_names.include?(title.content.to_s)
          end

          # Series names already covered by <seriesInfo> or <refcontent> built
          # from the item's identifiers.
          def identifier_series_names
            @identifier_series_names ||=
              identifier_to_seriesinfo.map(&:name) +
              subseries_identifiers.map { |id| id.split.first }
          end

          def series_title(ser)
            ser.title.find { |title| title.content.to_s != "DOI" }
          end

          # --- Identifiers ---

          def identifier_to_seriesinfo
            return [] unless home_standard?

            authoritative_identifiers.filter_map { |id| id_to_seriesinfo(id) }
          end

          def id_to_seriesinfo(id)
            name, value = split_identifier(id)
            return nil unless name

            # No `stream` attribute here: in v3 the stream is carried by the
            # <stream> element, and duplicating it only adds noise.
            ::Rfcxml::V3::SeriesInfo.new(name: name, value: value,
                                         status: seriesinfo_status)
          end

          def split_identifier(id)
            if (match = DRAFT_ID_RE.match(id))
              ["Internet-Draft", match[:value]]
            elsif (match = HOME_ID_RE.match(id))
              [match[:name].upcase, match[:value]]
            end
          end

          # An untyped docidentifier that merely restates the reference's own
          # label ("ZELLER", "Grail") is a citation label, not a citation: keep
          # it only when the reference would otherwise show nothing at all.
          def label_echo?(docid)
            return false unless docid.type.nil?

            docid.content.to_s.casecmp(label_candidates.to_s).zero? &&
              reference_has_visible_text?
          end

          def label_candidates
            @item.docnumber || @item.id
          end

          def reference_has_visible_text?
            @item.title.any? || @item.formattedref ||
              @item.contributor.any? || @item.date.any?
          end

          def seriesinfo_status
            @item.status&.stage&.content
          end

          def authoritative_identifiers
            ids = subseries_identifiers + docidentifier_identifiers
            ids.reject { |id| id.empty? || IGNORED_ID_RE.match?(id) }.uniq
          end

          def docidentifier_identifiers
            @item.docidentifier.reject { |di| non_authoritative?(di) }
              .map { |di| di.content.to_s.strip }
          end

          def non_authoritative?(docid)
            NON_AUTHORITATIVE_TYPES.include?(docid.type) ||
              EXCLUDED_ID_TYPES.include?(docid.type) ||
              docid.scope == "trademark" ||
              DRAFT_ANCHOR_RE.match?(docid.content.to_s) ||
              label_echo?(docid)
          end

          def subseries_identifiers
            @item.series.filter_map do |ser|
              title = ser.title.find { |t| SUBSERIES.include?(t.content.to_s) }
              "#{title.content} #{ser.number}" if title && ser.number
            end
          end

          def home_standard?
            @item.contributor.any? do |contrib|
              org = contrib.organization or next false

              ([org.abbreviation&.content] + org.name.map(&:content))
                .compact.any? { |name| HOME_ORGS.include?(name.to_s) }
            end
          end

          # --- refcontent ---

          def create_refcontent
            (identifier_refcontent + series_refcontent)
              .map { |text| ::Rfcxml::V3::Refcontent.new(content: text) }
          end

          # Identifiers that cannot be expressed as <seriesInfo> — either
          # because the document is not an IETF one, or because the identifier
          # does not split into a series name and number.
          # Whatever <seriesInfo> already states must not be repeated here,
          # whichever route put it there.
          def identifier_refcontent
            ids = authoritative_identifiers.reject { |id| in_seriesinfo?(id) }
            ids.empty? ? [] : [ids.join(", ")]
          end

          def in_seriesinfo?(id)
            name, value = split_identifier(id)
            return false if name.nil?

            create_seriesinfo.any? { |si| si.name == name && si.value == value }
          end

          def series_refcontent
            (renderable_series - numbered_series).filter_map do |ser|
              text = ser.formattedref&.content&.to_s || series_description(ser)
              text unless text.strip.empty?
            end
          end

          def series_description(ser)
            [series_title(ser)&.content, ser.run, ser.organization,
             ser.place&.city, series_dates(ser)]
              .map(&:to_s).reject(&:empty?).join(", ")
          end

          def series_dates(ser)
            [ser.from, ser.to].compact.map(&:to_s).reject(&:empty?).join("-")
          end

          # --- stream ---

          # Values outside the grammar (relaton-ietf also has "Legacy") have no
          # valid representation, so they are dropped with a warning rather
          # than emitted as invalid XML.
          def create_stream
            value = ext_stream || series_stream
            return nil if value.nil?

            stream = STREAMS[value.to_s.strip.downcase]
            unless stream
              Util.warn "Dropping stream `#{value}`: not an RFC XML v3 stream"
            end
            stream
          end

          def ext_stream
            @item.ext.respond_to?(:stream) ? @item.ext.stream : nil
          end

          def series_stream
            ser = @item.series.find { |s| s.type == "stream" }
            ser && ser.title.first&.content
          end

          # --- Contributors ---

          # Every relaton-ietf RFC record carries publisher and authorizer
          # contributors, and published RFC XML never lists those as authors.
          # So: authors and editors if there are any, and only otherwise fall
          # back to the wider set, which keeps a translator-only monograph its
          # translator (metanorma-ietf#301).
          def contributors_for_authors
            contribs = super
            primary = contribs.select { |c| role?(c, %w[author editor]) }
            primary.any? ? primary : contribs.select { |c| fallback_author?(c) }
          end

          def role?(contrib, types)
            contrib.role.any? { |r| types.include?(r.type) }
          end

          # A contributor with no role at all is an author by default; that is
          # how most non-IETF bibitems are written.
          def fallback_author?(contrib)
            contrib.role.empty? || role?(contrib, FALLBACK_ROLES)
          end

          # --- ascii folding ---

          def create_authors
            super.each do |author|
              author.ascii_fullname = ascii(author.fullname)
              author.ascii_surname = ascii(author.surname)
              author.ascii_initials = ascii(author.initials)
            end
          end

          def create_organization(contrib)
            org = super or return nil

            org.ascii = ascii(Array(org.content).join)
            org
          end

          # Transliterate to bare ASCII: expand the letters above, then strip
          # the combining marks NFKD leaves behind. "Nürk" -> "Nurk",
          # "Ö." -> "O.", "Sørensen" -> "Sorensen".
          def ascii(str)
            return nil if str.nil?

            folded = str.to_s.gsub(/[#{TRANSLITERATIONS.keys.join}]/,
                                   TRANSLITERATIONS)
              .unicode_normalize(:nfkd)
              .encode("ASCII", invalid: :replace, undef: :replace, replace: "")
            # Folding a non-Latin script leaves only the punctuation and
            # spacing behind ("Νίκος Παπαδόπουλος" -> " "), which is worse than
            # no attribute at all. Real transliteration is the caller's policy.
            folded.match?(/[[:alnum:]]/) ? folded : nil
          end
        end
      end
    end
  end
end
