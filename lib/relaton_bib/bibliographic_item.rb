# frozen_string_literal: true

require "relaton_bib/typed_uri"
require "relaton_bib/document_identifier"
require "relaton_bib/copyright_association"
require "relaton_bib/formatted_string"
require "relaton_bib/contribution_info"
require "relaton_bib/bibliographic_date"
require "relaton_bib/series"
require "relaton_bib/document_status"
require "relaton_bib/organization"
require "relaton_bib/document_relation_collection"
require "relaton_bib/typed_title_string"
require "relaton_bib/formatted_ref"
require "relaton_bib/medium"
require "relaton_bib/classification"
require "relaton_bib/validity"
require "relaton_bib/document_relation"
require "relaton_bib/bib_item_locality"
require "relaton_bib/xml_parser"
require "relaton_bib/bibtex_parser"
require "relaton_bib/biblio_note"
require "relaton_bib/biblio_version"
require "relaton_bib/workers_pool"
require "relaton_bib/hash_converter"
require "relaton_bib/place"
require "relaton_bib/structured_identifier"
require "relaton_bib/editorial_group"
require "relaton_bib/ics"
require "relaton_bib/bibliographic_size"
require "relaton_bib/edition"

module RelatonBib
  # Bibliographic item
  class BibliographicItem
    include RelatonBib

    TYPES = %W[article book booklet conference manual proceedings presentation
               thesis techreport standard unpublished map electronic\sresource
               audiovisual film video broadcast graphic_work music patent
               inbook incollection inproceedings journal software website
               webresource dataset archival social_media alert message
               conversation misc].freeze

    # @return [Boolean, nil]
    attr_accessor :all_parts

    # @return [String, nil]
    attr_reader :id, :type, :docnumber, :doctype, :subdoctype

    # @return [RelatonBib::Edition, nil] <description>
    attr_reader :edition

    # @!attribute [r] title
    # @return [RelatonBib::TypedTitleStringCollection]

    # @return [Array<RelatonBib::TypedUri>]
    attr_reader :link

    # @return [Array<RelatonBib::DocumentIdentifier>]
    attr_reader :docidentifier

    # @return [Array<RelatonBib::BibliographicDate>]
    attr_accessor :date

    # @return [Array<RelatonBib::ContributionInfo>]
    attr_reader :contributor

    # @return [Array<RelatonBib::BibliographicItem::Version>]
    attr_reader :version

    # @return [RelatonBib::BiblioNoteCollection]
    attr_reader :biblionote

    # @return [Array<String>] language Iso639 code
    attr_reader :language

    # @return [Array<String>] script Iso15924 code
    attr_reader :script

    # @return [RelatonBib::FormattedRef, nil]
    attr_reader :formattedref

    # @!attribute [r] abstract
    #   @return [Array<RelatonBib::FormattedString>]

    # @return [RelatonBib::DocumentStatus, nil]
    attr_reader :status

    # @return [Array<RelatonBib::CopyrightAssociation>]
    attr_reader :copyright

    # @return [RelatonBib::DocRelationCollection]
    attr_reader :relation

    # @return [Array<RelatonBib::Series>]
    attr_reader :series

    # @return [RelatonBib::Medium, nil]
    attr_reader :medium

    # @return [Array<RelatonBib::Place>]
    attr_reader :place

    # @return [Array<RelatonBib::Locality, RelatonBib::LocalityStack>]
    attr_reader :extent

    # @return [Array<Strig>]
    attr_reader :accesslocation, :license

    # @return [Array<Relaton::Classification>]
    attr_reader :classification

    # @return [RelatonBib:Validity, nil]
    attr_reader :validity

    # @return [Date]
    attr_reader :fetched

    # @return [Array<RelatonBib::LocalizedString>]
    attr_reader :keyword

    # @return [RelatonBib::EditorialGroup, nil]
    attr_reader :editorialgroup

    # @return [Array<RelatonBib:ICS>]
    attr_reader :ics

    # @return [RelatonBib::StructuredIdentifierCollection]
    attr_reader :structuredidentifier

    # @return [RelatonBib::BibliographicSize, nil]
    attr_reader :size

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    # @param id [String, nil]
    # @param title [RelatonBib::TypedTitleStringCollection,
    #   Array<Hash, RelatonBib::TypedTitleString>]
    # @param formattedref [RelatonBib::FormattedRef, nil]
    # @param type [String, nil]
    # @param docid [Array<RelatonBib::DocumentIdentifier>]
    # @param docnumber [String, nil]
    # @param language [Arra<String>]
    # @param script [Array<String>]
    # @param docstatus [RelatonBib::DocumentStatus, nil]
    # @param edition [RelatonBib::Edition, nil]
    # @param version [Array<RelatonBib::BibliographicItem::Version>]
    # @param biblionote [RelatonBib::BiblioNoteCollection]
    # @param series [Array<RelatonBib::Series>]
    # @param medium [RelatonBib::Medium, NilClas]
    # @param place [Array<String, RelatonBib::Place>]
    # @param extent [Array<Relaton::Locality, RelatonBib::LocalityStack>]
    # @param accesslocation [Array<String>]
    # @param classification [Array<RelatonBib::Classification>]
    # @param validity [RelatonBib:Validity, nil]
    # @param fetched [Date, nil] default nil
    # @param keyword [Array<String>]
    # @param doctype [String]
    # @param subdoctype [String]
    # @param editorialgroup [RelatonBib::EditorialGroup, nil]
    # @param ics [Array<RelatonBib::ICS>]
    # @param structuredidentifier [RelatonBib::StructuredIdentifierCollection]
    # @param size [RelatonBib::BibliographicSize, nil]
    #
    # @param copyright [Array<Hash, RelatonBib::CopyrightAssociation>]
    # @option copyright [Array<Hash, RelatonBib::ContributionInfo>] :owner
    # @option copyright [String] :from
    # @option copyright [String, nil] :to
    # @option copyright [String, nil] :scope
    #
    # @param date [Array<Hash, RelatonBib::BibliographicDate>]
    # @option date [String] :type
    # @option date [String, nil] :from required if :on is nil
    # @option date [String, nil] :to
    # @option date [String, nil] :on required if :from is nil
    #
    # @param contributor [Array<Hash, RelatonBib::ContributionInfo>]
    # @option contributor [RealtonBib::Organization, RelatonBib::Person] :entity
    # @option contributor [String] :type
    # @option contributor [String] :from
    # @option contributor [String] :to
    # @option contributor [String] :abbreviation
    # @option contributor [Array<Array<String,Array<String>>>] :role
    #
    # @param abstract [Array<Hash, RelatonBib::FormattedString>]
    # @option abstract [String] :content
    # @option abstract [String] :language
    # @option abstract [String] :script
    # @option abstract [String] :format
    #
    # @param relation [Array<Hash>]
    # @option relation [String] :type
    # @option relation [RelatonBib::BibliographicItem,
    #                   RelatonIso::IsoBibliographicItem] :bibitem
    # @option relation [Array<RelatonBib::Locality,
    #                   RelatonBib::LocalityStack>] :locality
    # @option relation [Array<RelatonBib::SourceLocality,
    #                   RelatonBib::SourceLocalityStack>] :source_locality
    #
    # @param link [Array<Hash, RelatonBib::TypedUri>]
    # @option link [String] :type
    # @option link [String] :content
    def initialize(**args)
      if args[:type] && !TYPES.include?(args[:type])
        warn %{[relaton-bib] document type "#{args[:type]}" is invalid.}
      end

      @title = TypedTitleStringCollection.new(args[:title])

      @date = (args[:date] || []).map do |d|
        d.is_a?(Hash) ? BibliographicDate.new(**d) : d
      end

      @contributor = (args[:contributor] || []).map do |c|
        if c.is_a? Hash
          e = c[:entity].is_a?(Hash) ? Organization.new(**c[:entity]) : c[:entity]
          ContributionInfo.new(entity: e, role: c[:role])
        else c
        end
      end

      @abstract = (args[:abstract] || []).map do |a|
        a.is_a?(Hash) ? FormattedString.new(**a) : a
      end

      @copyright = args.fetch(:copyright, []).map do |c|
        c.is_a?(Hash) ? CopyrightAssociation.new(**c) : c
      end

      @docidentifier  = args[:docid] || []
      @formattedref   = args[:formattedref] if title.empty?
      @id             = args[:id] || makeid(nil, false)
      @type           = args[:type]
      @docnumber      = args[:docnumber]
      @edition        = case args[:edition]
                        when Hash then Edition.new(**args[:edition])
                        when String then Edition.new(content: args[:edition])
                        else args[:edition]
                        end
      @version        = args.fetch :version, []
      @biblionote     = args.fetch :biblionote, BiblioNoteCollection.new([])
      @language       = args.fetch :language, []
      @script         = args.fetch :script, []
      @status         = args[:docstatus]
      @relation       = DocRelationCollection.new(args[:relation] || [])
      @link           = args.fetch(:link, []).map do |s|
        case s
        when Hash then TypedUri.new(**s)
        when String then TypedUri.new(content: s)
        else s
        end
      end
      @series         = args.fetch :series, []
      @medium         = args[:medium]
      @place          = args.fetch(:place, []).map do |pl|
        pl.is_a?(String) ? Place.new(name: pl) : pl
      end
      @extent         = args[:extent] || []
      @size           = args[:size]
      @accesslocation = args.fetch :accesslocation, []
      @classification = args.fetch :classification, []
      @validity       = args[:validity]
      # we should pass the fetched arg from scrappers
      @fetched        = args.fetch :fetched, nil
      @keyword        = (args[:keyword] || []).map do |kw|
        case kw
        when Hash then LocalizedString.new(kw[:content], kw[:language], kw[:script])
        when String then LocalizedString.new(kw)
        else kw
        end
      end
      @license        = args.fetch :license, []
      @doctype        = args[:doctype]
      @subdoctype     = args[:subdoctype]
      @editorialgroup = args[:editorialgroup]
      @ics            = args.fetch :ics, []
      @structuredidentifier = args[:structuredidentifier]
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    # @param hash [Hash]
    # @return [RelatonBipm::BipmBibliographicItem]
    def self.from_hash(hash)
      item_hash = Object.const_get(name.split("::")[0])::HashConverter.hash_to_bib(hash)
      new(**item_hash)
    end

    # @param lang [String] language code Iso639
    # @return [RelatonBib::FormattedString, Array<RelatonBib::FormattedString>]
    def abstract(lang: nil)
      if lang
        @abstract.detect { |a| a.language&.include? lang }
      else
        @abstract
      end
    end

    # @param id [RelatonBib::DocumentIdentifier]
    # @param attribute [boolean, nil]
    # @return [String]
    def makeid(id, attribute)
      return nil if attribute && !@id_attribute

      id ||= @docidentifier.reject { |i| i.type == "DOI" }[0]
      return unless id

      # contribs = publishers.map { |p| p&.entity&.abbreviation }.join '/'
      # idstr = "#{contribs}#{delim}#{id.project_number}"
      # idstr = id.project_number.to_s
      idstr = id.id.gsub(/:/, "-").gsub(/\s/, "")
      # if id.part_number&.size&.positive? then idstr += "-#{id.part_number}"
      idstr.strip
    end

    # @param identifier [RelatonBib::DocumentIdentifier]
    # @param options [Hash]
    # @option options [boolean, nil] :no_year
    # @option options [boolean, nil] :all_parts
    # @return [String]
    def shortref(identifier, **opts) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/AbcSize,Metrics/PerceivedComplexity
      pubdate = date.select { |d| d.type == "published" }
      year = if opts[:no_year] || pubdate.empty? then ""
             else ":#{pubdate&.first&.on(:year)}"
             end
      year += ": All Parts" if opts[:all_parts] || @all_parts

      "#{makeid(identifier, false)}#{year}"
    end

    # @param opts [Hash]
    # @option opts [Nokogiri::XML::Builder] :builder XML builder
    # @option opts [Boolean] :bibdata
    # @option opts [Symbol, nil] :date_format (:short), :full
    # @option opts [String, Symbol] :lang language
    # @return [String] XML
    def to_xml(**opts, &block)
      if opts[:builder]
        render_xml(**opts, &block)
      else
        Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
          render_xml builder: xml, **opts, &block
        end.doc.root.to_xml
      end
    end

    #
    # Render BibXML (RFC)
    #
    # @param [Nokogiri::XML::Builder, nil] builder
    # @param [Boolean] include_keywords (false)
    #
    # @return [String, Nokogiri::XML::Builder::NodeBuilder] XML
    #
    def to_bibxml(builder = nil, include_keywords: false)
      if builder
        render_bibxml builder, include_keywords
      else
        Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
          render_bibxml xml, include_keywords
        end.doc.root.to_xml
      end
    end

    # @return [Hash]
    def to_hash # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      hash = {}
      hash["id"] = id if id
      hash["title"] = single_element_array(title) if title&.any?
      hash["link"] = single_element_array(link) if link&.any?
      hash["type"] = type if type
      hash["docid"] = single_element_array(docidentifier) if docidentifier&.any?
      hash["docnumber"] = docnumber if docnumber
      hash["date"] = single_element_array(date) if date&.any?
      if contributor&.any?
        hash["contributor"] = single_element_array(contributor)
      end
      hash["edition"] = edition.to_hash if edition
      hash["version"] = version.map &:to_hash if version.any?
      hash["revdate"] = revdate if revdate
      hash["biblionote"] = single_element_array(biblionote) if biblionote&.any?
      hash["language"] = single_element_array(language) if language&.any?
      hash["script"] = single_element_array(script) if script&.any?
      hash["formattedref"] = formattedref.to_hash if formattedref
      hash["abstract"] = single_element_array(abstract) if abstract&.any?
      hash["docstatus"] = status.to_hash if status
      hash["copyright"] = single_element_array(copyright) if copyright&.any?
      hash["relation"] = single_element_array(relation) if relation&.any?
      hash["series"] = single_element_array(series) if series&.any?
      hash["medium"] = medium.to_hash if medium
      hash["place"] = single_element_array(place) if place&.any?
      hash["extent"] = single_element_array(extent) if extent&.any?
      hash["size"] = size.to_hash if size&.any?
      if accesslocation&.any?
        hash["accesslocation"] = single_element_array(accesslocation)
      end
      if classification&.any?
        hash["classification"] = single_element_array(classification)
      end
      hash["validity"] = validity.to_hash if validity
      hash["fetched"] = fetched.to_s if fetched
      hash["keyword"] = single_element_array(keyword) if keyword&.any?
      hash["license"] = single_element_array(license) if license&.any?
      hash["doctype"] = doctype if doctype
      hash["subdoctype"] = subdoctype if subdoctype
      if editorialgroup&.presence?
        hash["editorialgroup"] = editorialgroup.to_hash
      end
      hash["ics"] = single_element_array ics if ics.any?
      if structuredidentifier&.presence?
        hash["structuredidentifier"] = structuredidentifier.to_hash
      end
      hash
    end

    #
    # Reander BibTeX
    #
    # @param bibtex [BibTeX::Bibliography, nil]
    #
    # @return [String]
    #
    def to_bibtex(bibtex = nil)
      bibtext_item(bibtex).to_s
    end

    #
    # Render citeproc
    #
    # @param bibtex [BibTeX::Bibliography, nil]
    #
    # @return [Hash] citeproc
    #
    def to_citeproc(bibtex = nil)
      bibtext_item(bibtex).to_citeproc.map { |cp| cp.transform_keys(&:to_s) }
    end

    # @param lang [String, nil] language code Iso639
    # @return [RelatonIsoBib::TypedTitleStringCollection]
    def title(lang: nil)
      @title.lang lang
    end

    # @param type [Symbol] type of url, can be :src/:obp/:rss
    # @return [String]
    def url(type = :src)
      @link.detect { |s| s.type == type.to_s }&.content&.to_s
    end

    def abstract=(value)
      @abstract = value
    end

    def deep_clone
      dump = Marshal.dump self
      Marshal.load dump # rubocop:disable Security/MarshalLoad
    end

    def disable_id_attribute
      @id_attribute = false
    end

    # remove title part components and abstract
    def to_all_parts # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength,Metrics/PerceivedComplexity
      me = deep_clone
      me.disable_id_attribute
      me.relation << DocumentRelation.new(type: "instance", bibitem: self)
      me.language.each do |l|
        me.title.delete_title_part!
        ttl = me.title.select do |t|
          t.type != "main" && t.title.language&.include?(l)
        end
        tm_en = ttl.map { |t| t.title.content }.join " – "
        me.title.detect do |t|
          t.type == "main" && t.title.language&.include?(l)
        end&.title&.content = tm_en
      end
      me.abstract = []
      me.docidentifier.each(&:remove_part)
      me.docidentifier.each(&:all_parts)
      me.structuredidentifier.remove_part
      me.structuredidentifier.all_parts
      me.docidentifier.each &:remove_date
      me.structuredidentifier&.remove_date
      me.all_parts = true
      me
    end

    # convert ISO:yyyy reference to reference to most recent
    # instance of reference, removing date-specific infomration:
    # date of publication, abstracts. Make dated reference Instance relation
    # of the redacated document
    def to_most_recent_reference
      me = deep_clone
      disable_id_attribute
      me.relation << DocumentRelation.new(type: "instance", bibitem: self)
      me.abstract = []
      me.date = []
      me.docidentifier.each &:remove_date
      me.structuredidentifier&.remove_date
      me.id&.sub!(/-[12]\d\d\d/, "")
      me
    end

    # If revision_date exists then returns it else returns published date or nil
    # @return [String, nil]
    def revdate # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      @revdate ||= if (v = version.detect &:revision_date)
                     v.revision_date
                   else
                     date.detect { |d| d.type == "published" }&.on&.to_s
                   end
    end

    # @param prefix [String]
    # @return [String]
    def to_asciibib(prefix = "") # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      pref = prefix.empty? ? prefix : "#{prefix}."
      out = prefix.empty? ? "[%bibitem]\n== {blank}\n" : ""
      out += "#{pref}id:: #{id}\n" if id
      out += "#{pref}fetched:: #{fetched}\n" if fetched
      title.each { |t| out += t.to_asciibib(prefix, title.size) }
      out += "#{pref}type:: #{type}\n" if type
      docidentifier.each do |di|
        out += di.to_asciibib prefix, docidentifier.size
      end
      out += "#{pref}docnumber:: #{docnumber}\n" if docnumber
      out += edition.to_asciibib(prefix) if edition
      language.each { |l| out += "#{pref}language:: #{l}\n" }
      script.each { |s| out += "#{pref}script:: #{s}\n" }
      version.each { |v| out += v.to_asciibib prefix, version.size }
      biblionote&.each { |b| out += b.to_asciibib prefix, biblionote.size }
      out += status.to_asciibib prefix if status
      date.each { |d| out += d.to_asciibib prefix, date.size }
      abstract.each do |a|
        out += a.to_asciibib "#{pref}abstract", abstract.size
      end
      copyright.each { |c| out += c.to_asciibib prefix, copyright.size }
      link.each { |l| out += l.to_asciibib prefix, link.size }
      out += medium.to_asciibib prefix if medium
      place.each { |pl| out += pl.to_asciibib prefix, place.size }
      extent.each { |ex| out += ex.to_asciibib "#{pref}extent", extent.size }
      out += size.to_asciibib pref if size
      accesslocation.each { |al| out += "#{pref}accesslocation:: #{al}\n" }
      classification.each do |cl|
        out += cl.to_asciibib prefix, classification.size
      end
      out += validity.to_asciibib prefix if validity
      contributor.each do |c|
        out += c.to_asciibib "contributor.*", contributor.size
      end
      out += relation.to_asciibib prefix if relation
      series.each { |s| out += s.to_asciibib prefix, series.size }
      out += "#{pref}doctype:: #{doctype}\n" if doctype
      out += "#{pref}subdoctype:: #{subdoctype}\n" if subdoctype
      out += "#{pref}formattedref:: #{formattedref}\n" if formattedref
      keyword.each { |kw| out += kw.to_asciibib "#{pref}keyword", keyword.size }
      out += editorialgroup.to_asciibib prefix if editorialgroup
      ics.each { |i| out += i.to_asciibib prefix, ics.size }
      out += structuredidentifier.to_asciibib prefix if structuredidentifier
      out
    end

    private

    #
    # Create BibTeX item for this document
    #
    # @param [BibTeX::Bibliography, nil] bibtex <description>
    #
    # @return [BibTeX::Bibliography] BibTeX bibliography
    #
    def bibtext_item(bibtex) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
      item = BibTeX::Entry.new
      item.type = bibtex_type
      item.key = id
      title.to_bibtex item
      item.edition = edition.content if edition
      bibtex_author item
      bibtex_contributor item
      item.address = place.first.name if place.any?
      bibtex_note item
      bibtex_relation item
      bibtex_extent item
      bibtex_date item
      bibtex_series item
      bibtex_classification item
      item.keywords = keyword.map(&:content).join(", ") if keyword.any?
      bibtex_docidentifier item
      item.timestamp = fetched.to_s if fetched
      bibtex_link item
      bibtex ||= BibTeX::Bibliography.new
      bibtex << item
      bibtex
    end

    # @return [String]
    def bibtex_type
      case type
      when "standard", nil then "misc"
      else type
      end
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength

    # @param [BibTeX::Entry]
    def bibtex_author(item) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      authors = contributor.select do |c|
        c.entity.is_a?(Person) && c.role.map(&:type).include?("author")
      end.map &:entity

      return unless authors.any?

      item.author = authors.map do |a|
        if a.name.surname
          "#{a.name.surname}, #{a.name.forename.map(&:to_s).join(' ')}"
        else
          a.name.completename.to_s
        end
      end.join " and "
    end

    # @param [BibTeX::Entry]
    def bibtex_contributor(item) # rubocop:disable Metrics/CyclomaticComplexity
      contributor.each do |c|
        rls = c.role.map(&:type)
        if rls.include?("publisher") then item.publisher = c.entity.name
        elsif rls.include?("distributor")
          case type
          when "techreport" then item.institution = c.entity.name
          when "inproceedings", "conference", "manual", "proceedings"
            item.organization = c.entity.name
          when "mastersthesis", "phdthesis" then item.school = c.entity.name
          end
        end
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    # @param [BibTeX::Entry]
    def bibtex_note(item) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/AbcSize
      biblionote.each do |n|
        case n.type
        when "annote" then item.annote = n.content
        when "howpublished" then item.howpublished = n.content
        when "comment" then item.comment = n.content
        when "tableOfContents" then item.content = n.content
        when nil then item.note = n.content
        end
      end
    end

    # @param [BibTeX::Entry]
    def bibtex_relation(item)
      rel = relation.detect { |r| r.type == "partOf" }
      if rel
        title_main = rel.bibitem.title.detect { |t| t.type == "main" }
        item.booktitle = title_main.title.content
      end
    end

    # @param [BibTeX::Entry]
    def bibtex_extent(item)
      extent.each { |e| e.to_bibtex(item) }
    end

    # @param [BibTeX::Entry]
    def bibtex_date(item)
      date.each do |d|
        case d.type
        when "published"
          item.year = d.on :year
          item.month = d.on :month
        when "accessed" then item.urldate = d.on.to_s
        end
      end
    end

    # @param [BibTeX::Entry]
    def bibtex_series(item)
      series.each do |s|
        case s.type
        when "journal"
          item.journal = s.title.title
          item.number = s.number if s.number
        when nil then item.series = s.title.title
        end
      end
    end

    # @param [BibTeX::Entry]
    def bibtex_classification(item)
      classification.each do |c|
        case c.type
        when "type" then item["type"] = c.value
        # when "keyword" then item.keywords = c.value
        when "mendeley" then item["mendeley-tags"] = c.value
        end
      end
    end

    # @param [BibTeX::Entry]
    def bibtex_docidentifier(item)
      docidentifier.each do |i|
        case i.type
        when "isbn" then item.isbn = i.id
        when "lccn" then item.lccn = i.id
        when "issn" then item.issn = i.id
        end
      end
    end

    # @param [BibTeX::Entry]
    def bibtex_link(item)
      link.each do |l|
        case l.type
        when "doi" then item.doi = l.content
        when "file" then item.file2 = l.content
        when "src" then item.url = l.content
        end
      end
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    # rubocop:disable Style/NestedParenthesizedCalls, Metrics/BlockLength

    # @param opts [Hash]
    # @option opts [Nokogiri::XML::Builder] :builder XML builder
    # @option opts [Boolean] bibdata
    # @option opts [Symbol, nil] :date_format (:short), :full
    # @option opts [String] :lang language
    def render_xml(**opts)
      root = opts[:bibdata] ? :bibdata : :bibitem
      xml = opts[:builder].send(root) do |builder|
        builder.fetched fetched if fetched
        title.to_xml(**opts)
        formattedref&.to_xml builder
        link.each { |s| s.to_xml builder }
        docidentifier.each { |di| di.to_xml(**opts) }
        builder.docnumber docnumber if docnumber
        date.each { |d| d.to_xml builder, **opts }
        contributor.each do |c|
          builder.contributor do
            c.role.each { |r| r.to_xml(**opts) }
            c.to_xml(**opts)
          end
        end
        edition&.to_xml builder
        version.each { |v| v.to_xml builder }
        biblionote.to_xml(**opts)
        opts[:note]&.each do |n|
          builder.note(n[:text], format: "text/plain", type: n[:type])
        end
        language.each { |l| builder.language l }
        script.each { |s| builder.script s }
        abstr = abstract.select { |ab| ab.language&.include? opts[:lang] }
        abstr = abstract unless abstr.any?
        abstr.each { |a| builder.abstract { a.to_xml(builder) } }
        status&.to_xml builder
        copyright&.each { |c| c.to_xml(**opts) }
        relation.each { |r| r.to_xml builder, **opts }
        series.each { |s| s.to_xml builder }
        medium&.to_xml builder
        place.each { |pl| pl.to_xml builder }
        extent.each { |e| builder.extent { e.to_xml builder } }
        size&.to_xml builder
        accesslocation.each { |al| builder.accesslocation al }
        license.each { |l| builder.license l }
        classification.each { |cls| cls.to_xml builder }
        kwrd = keyword.select { |kw| kw.language&.include? opts[:lang] }
        kwrd = keyword unless kwrd.any?
        kwrd.each { |kw| builder.keyword { kw.to_xml(builder) } }
        validity&.to_xml builder
        if block_given? then yield builder
        elsif opts[:bibdata] && (doctype || editorialgroup || ics&.any? ||
                                 structuredidentifier&.presence?)
          builder.ext do |b|
            b.doctype doctype if doctype
            b.subdoctype subdoctype if subdoctype
            editorialgroup&.to_xml b
            ics.each { |i| i.to_xml b }
            structuredidentifier&.to_xml b
          end
        end
      end
      xml[:id] = id if id && !opts[:bibdata] && !opts[:embedded]
      xml[:type] = type if type
      xml
    end
    # rubocop:enable Style/NestedParenthesizedCalls, Metrics/BlockLength

    #
    # Render BibXML (RFC, BCP)
    #
    # @param [Nokogiri::XML::Builder] builder
    # @param [Boolean] include_bibdata
    #
    def render_bibxml(builder, include_keywords)
      target = link.detect { |l| l.type.casecmp("src").zero? } ||
        link.detect { |l| l.type.casecmp("doi").zero? }
      bxml = if docnumber&.match(/^BCP/) || (docidentifier.detect(&:primary)&.id ||
                  docidentifier[0].id).include?("BCP")
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
        relation.each do |r|
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
    def render_bibxml_ref(builder, include_keywords)
      builder.reference(**ref_attrs) do |xml|
        if title.any? || contributor.any? || date.any? || abstract.any? ||
            editorialgroup&.technical_committee&.any? ||
            (include_keywords && keyword.any?)
          xml.front do
            xml.title title[0].title.content if title.any?
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

    def render_format(builder)
      link.select { |l| l.type == "TXT" }.each do |l|
        builder.format type: l.type, target: l.content
      end
    end

    #
    # Create reference attributes
    #
    # @return [Hash<Symbol=>String>] attributes
    #
    def ref_attrs
      discopes = %w[anchor docName number]
      attrs = docidentifier.each_with_object({}) do |di, h|
        next unless discopes.include?(di.scope)

        h[di.scope.to_sym] = di.id
      end
      return attrs if attrs.any?

      docidentifier.first&.tap do |di|
        anchor = di.type == "IANA" ? di.id.split[1..-1].join(" ").upcase : di.id
        return { anchor: anchor.gsub(" ", ".") }
      end
    end

    #
    # Render keyword
    #
    # @param [Nokogiri::XML::Builder] builder xml builder
    #
    def render_keyword(builder)
      keyword.each { |kw| builder.keyword kw.content }
    end

    #
    # Render workgroup
    #
    # @param [Nokogiri::XML::Builder] builder xml builder
    #
    def render_workgroup(builder)
      editorialgroup&.technical_committee&.each do |tc|
        builder.workgroup tc.workgroup.name
      end
    end

    #
    # Render abstract
    #
    # @param [Nokogiri::XML::Builder] builder xml builder
    #
    def render_abstract(builder)
      return unless abstract.any?

      builder.abstract { |xml| xml << abstract[0].content.gsub(/(<\/?)p(>)/, '\1t\2') }
    end

    #
    # Render date
    #
    # @param [Nokogiri::XML::Builder] builder xml builder
    #
    def render_date(builder)
      dt = date.detect { |d| d.type == "published" }
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
    # Render seriesinfo
    #
    # @param [Nokogiri::XML::Builder] builder xml builder
    #
    def render_seriesinfo(builder)
      docidentifier.each do |di|
        if BibXMLParser::SERIESINFONAMES.include? di.type
          builder.seriesInfo(name: di.type, value: di.id)
        end
      end
      # di_types = docidentifier.map(&:type)
      series.select do |s|
        s.title && # !di_types.include?(s.title.title.to_s) &&
          !BibXMLParser::SERIESINFONAMES.include?(s.title.title.to_s)
      end.uniq { |s| s.title.title.to_s }.each do |s|
        si = builder.seriesInfo(name: s.title.title.to_s)
        si[:value] = s.number if s.number
      end
    end

    #
    # Render authors
    #
    # @param [Nokogiri::XML::Builder] builder xml builder
    #
    def render_authors(builder)
      contributor.each do |c|
        builder.author do |xml|
          xml.parent[:role] = "editor" if c.role.detect { |r| r.type == "editor" }
          if c.entity.is_a?(Person) then render_person xml, c.entity
          else render_organization xml, c.entity
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
    def render_address(builder, contrib)
      # addr = contrib.entity.contact.reject do |cn|
      #   cn.is_a?(Address) && cn.postcode.nil?
      # end
      if contrib.entity.contact.any?
        builder.address do |xml|
          address = contrib.entity.contact.detect { |cn| cn.is_a? Address }
          if address
            xml.postal do
              xml.city address.city if address.city
              xml.code address.postcode if address.postcode
              xml.country address.country if address.country
              xml.region address.state if address.state
              xml.street address.street[0] if address.street.any?
            end
          end
          render_contact xml, contrib.entity.contact
        end
      end
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
    def render_person(builder, person)
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
    def render_organization(builder, org)
      # return unless org

      ab = org&.abbreviation&.content
      on = org&.name&.first&.content
      orgname = if BibXMLParser::ORGNAMES.key?(ab) then ab
                else BibXMLParser::ORGNAMES.key(on) || on || ab
                end
      o = builder.organization orgname
      o[:abbrev] = ab if ab
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  end
end
