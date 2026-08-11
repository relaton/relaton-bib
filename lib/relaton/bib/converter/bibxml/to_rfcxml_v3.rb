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
          DRAFT_ID_RE = /I-D[.\s]\s*(?<value>\S+)/

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
            front.title ||= formattedref_title
            front.author = [unknown_author] if Array(front.author).empty?
            front
          end

          def formattedref_title
            content = @item.formattedref&.content or return nil

            ::Rfcxml::V3::Title.new(content: content.to_s)
          end

          def unknown_author
            ::Rfcxml::V3::Author.new(surname: "Unknown")
          end

          def create_seriesinfo
            docidentifier_to_seriesinfo + series_to_seriesinfo +
              identifier_to_seriesinfo
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
              docid.scope == "trademark"
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
          def identifier_refcontent
            ids = authoritative_identifiers
            ids = ids.reject { |id| split_identifier(id) } if home_standard?
            ids.empty? ? [] : [ids.join(", ")]
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
            folded.empty? ? nil : folded
          end
        end
      end
    end
  end
end
