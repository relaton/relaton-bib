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
require_relative "extent"
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

    TYPES = %W[article book booklet manual proceedings presentation
               thesis techreport standard unpublished map electronic\sresource
               audiovisual film video broadcast software graphic_work music
               patent inbook incollection inproceedings journal website
               webresource dataset archival social_media alert message
               conversation collection misc internal].freeze # internal is defined in isodoc grammar

    # @return [Boolean, nil]
    attr_accessor :all_parts

    # @return [String, nil]
    attr_reader :id, :type, :docnumber, :subdoctype

    # @return [RelatonBib::DocumentType] document type
    attr_reader :doctype

    # @return [RelatonBib::Edition, nil] edition
    attr_reader :edition

    # @!attribute [r] title
    # @return [RelatonBib::TypedTitleStringCollection]

    # @return [Array<RelatonBib::TypedUri>]
    attr_reader :link

    # @return [Array<RelatonBib::DocumentIdentifier>]
    attr_reader :docidentifier

    # @return [Array<RelatonBib::BibliographicDate>]
    attr_writer :date

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

    # @return [Array<RelatonBib::Extent>]
    attr_reader :extent

    # @return [Array<Strig>]
    attr_reader :accesslocation, :license

    # @return [Array<Relaton::Classification>]
    attr_reader :classification

    # @return [RelatonBib:Validity, nil]
    attr_reader :validity

    # @return [Date]
    attr_accessor :fetched

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
    # @param edition [RelatonBib::Edition, String, Integer, Float, nil]
    # @param version [Array<RelatonBib::BibliographicItem::Version>]
    # @param biblionote [RelatonBib::BiblioNoteCollection]
    # @param series [Array<RelatonBib::Series>]
    # @param medium [RelatonBib::Medium, nil]
    # @param place [Array<String, RelatonBib::Place>]
    # @param extent [Array<RelatonBib::Extent>]
    # @param accesslocation [Array<String>]
    # @param classification [Array<RelatonBib::Classification>]
    # @param validity [RelatonBib:Validity, nil]
    # @param fetched [Date, nil] default nil
    # @param keyword [Array<String>]
    # @param doctype [RelatonBib::DocumentType]
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
        Util.warn %{Type `#{args[:type]}` is invalid.}
      end

      @title = if args[:title].is_a?(TypedTitleStringCollection)
                 args[:title]
               else
                 TypedTitleStringCollection.new(args[:title])
               end

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

      @copyright = (args[:copyright] || []).map do |c|
        c.is_a?(Hash) ? CopyrightAssociation.new(**c) : c
      end

      @docidentifier  = args[:docid] || []
      @formattedref   = args[:formattedref] if title.empty?
      @id             = args[:id] || makeid(nil, false)
      @type           = args[:type]
      @docnumber      = args[:docnumber]
      @edition        = case args[:edition]
                        when Hash then Edition.new(**args[:edition])
                        when String, Integer, Float
                          Edition.new(content: args[:edition].to_s)
                        when Edition then args[:edition]
                        end
      @version        = args[:version] || []
      @biblionote     = args[:biblionote] || BiblioNoteCollection.new([])
      @language       = args[:language] || []
      @script         = args[:script] || []
      @status         = args[:docstatus]
      @relation       = DocRelationCollection.new(args[:relation] || [])
      @link           = (args[:link] || []).map do |s|
        case s
        when Hash then TypedUri.new(**s)
        when String then TypedUri.new(content: s)
        else s
        end
      end
      @series         = args[:series] || []
      @medium         = args[:medium]
      @place          = (args[:place] || []).map do |pl|
        pl.is_a?(String) ? Place.new(name: pl) : pl
      end
      @extent         = args[:extent] || []
      @size           = args[:size]
      @accesslocation = args[:accesslocation] || []
      @classification = args[:classification] || []
      @validity       = args[:validity]
      # we should pass the fetched arg from scrappers
      @fetched        = args[:fetched]
      @keyword        = (args[:keyword] || []).map do |kw|
        case kw
        when Hash then LocalizedString.new(kw[:content], kw[:language], kw[:script])
        when String then LocalizedString.new(kw)
        else kw
        end
      end
      @license        = args[:license] || []
      @doctype        = args[:doctype]
      @subdoctype     = args[:subdoctype]
      @editorialgroup = args[:editorialgroup]
      @ics            = args[:ics] || []
      @structuredidentifier = args[:structuredidentifier]
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    #
    # Fetch schema version
    #
    # @return [String] schema version
    #
    def schema
      @schema ||= schema_versions["relaton-models"]
    end

    #
    # Read schema versions from file
    #
    # @return [Hash{String=>String}] schema versions
    #
    def schema_versions
      JSON.parse File.read(File.join(__dir__, "../../grammars/versions.json"))
    end

    # @param hash [Hash]
    # @return [RelatonBipm::BipmBibliographicItem]
    def self.from_hash(hash)
      item_hash = Object.const_get(name.split("::")[0])::HashConverter.hash_to_bib(hash)
      new(**item_hash)
    end

    #
    # @param [String, nil] type if nil return all dates else return dates with type
    #
    # @return [Array<RelatonBib::BibliographicDate>]
    #
    def date(type: nil)
      type ? @date.select { |d| d.type == type } : @date
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

    # @param identifier [RelatonBib::DocumentIdentifier, nil]
    # @param attribute [Boolean, nil]
    # @return [String]
    def makeid(identifier, attribute)
      return nil if attribute && !@id_attribute

      identifier ||= @docidentifier.reject { |i| i.type == "DOI" }[0]
      return unless identifier

      idstr = identifier.id.gsub(/[:\/]/, "-").gsub(/[\s\(\)]/, "")
      idstr.strip
    end

    # @param identifier [RelatonBib::DocumentIdentifier]
    # @param options [Hash]
    # @option options [boolean, nil] :no_year
    # @option options [boolean, nil] :all_parts
    # @return [String]
    def shortref(identifier, **opts) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/AbcSize,Metrics/PerceivedComplexity
      pubdate = date.select { |d| d.type == "published" || d.type == "issued" }
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
      Renderer::BibXML.new(self).render builder: builder, include_keywords: include_keywords
    end

    # @return [Hash]
    def to_hash(embedded: false) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      hash = {}
      hash["schema-version"] = schema unless embedded
      hash["id"] = id if id
      hash["title"] = title.to_hash if title&.any?
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
      hash["extent"] = extent.map(&:to_hash) if extent&.any?
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
      if has_ext?
        hash["ext"] = {}
        hash["ext"]["schema-version"] = ext_schema if !embedded && respond_to?(:ext_schema) && ext_schema
        hash["ext"]["doctype"] = doctype.to_hash if doctype
        hash["ext"]["subdoctype"] = subdoctype if subdoctype
        hash["ext"]["editorialgroup"] = editorialgroup.to_hash if editorialgroup&.presence?
        hash["ext"]["ics"] = single_element_array ics if ics.any?
        hash["ext"]["structuredidentifier"] = structuredidentifier.to_hash if structuredidentifier&.presence?
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
      Renderer::BibtexBuilder.build(self, bibtex).to_s
    end

    #
    # Render citeproc
    #
    # @param bibtex [BibTeX::Bibliography, nil]
    #
    # @return [Hash] citeproc
    #
    def to_citeproc(bibtex = nil)
      Renderer::BibtexBuilder.build(self, bibtex).to_citeproc.map do |cp|
        cp.transform_keys(&:to_s)
      end
    end

    # @param lang [String, nil] language code Iso639
    # @return [RelatonIsoBib::TypedTitleStringCollection]
    def title(lang: nil)
      @title.lang lang
    end

    # @param type [Symbol] type of url, can be :src/:obp/:rss
    # @return [String, nil]
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
      me.relation << DocumentRelation.new(type: "instanceOf", bibitem: self)
      me.language.each do |l|
        me.title.delete_title_part!
        ttl = me.title.select do |t|
          t.type != "main" && t.title.language&.include?(l)
        end
        next if ttl.empty?

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
      me.relation << DocumentRelation.new(type: "instanceOf", bibitem: self)
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
      extent.each { |ex| out += ex.to_asciibib prefix, extent.size }
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
      out += doctype.to_asciibib prefix if doctype
      out += "#{pref}subdoctype:: #{subdoctype}\n" if subdoctype
      out += "#{pref}formattedref:: #{formattedref}\n" if formattedref
      keyword.each { |kw| out += kw.to_asciibib "#{pref}keyword", keyword.size }
      out += editorialgroup.to_asciibib prefix if editorialgroup
      ics.each { |i| out += i.to_asciibib prefix, ics.size }
      out += structuredidentifier.to_asciibib prefix if structuredidentifier
      out
    end

    private

    # @param opts [Hash]
    # @option opts [Nokogiri::XML::Builder] :builder XML builder
    # @option opts [Boolean] bibdata
    # @option opts [Symbol, nil] :date_format (:short), :full
    # @option opts [String] :lang language
    def render_xml(**opts) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      root = opts[:bibdata] ? :bibdata : :bibitem
      xml = opts[:builder].send(root) do |builder| # rubocop:disable Metrics/BlockLength
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
        extent.each { |e| e.to_xml builder }
        size&.to_xml builder
        accesslocation.each { |al| builder.accesslocation al }
        license.each { |l| builder.license l }
        classification.each { |cls| cls.to_xml builder }
        kwrd = keyword.select { |kw| kw.language&.include? opts[:lang] }
        kwrd = keyword unless kwrd.any?
        kwrd.each { |kw| builder.keyword { kw.to_xml(builder) } }
        validity&.to_xml builder
        if block_given? then yield builder
        elsif opts[:bibdata] && has_ext?
          ext = builder.ext do |b|
            doctype&.to_xml b
            b.subdoctype subdoctype if subdoctype
            editorialgroup&.to_xml b
            ics.each { |i| i.to_xml b }
            structuredidentifier&.to_xml b
          end
          ext["schema-version"] = ext_schema if !opts[:embedded] && respond_to?(:ext_schema) && ext_schema
        end
      end
      xml[:id] = id if id && !opts[:bibdata] && !opts[:embedded]
      xml[:type] = type if type
      xml["schema-version"] = schema unless opts[:embedded]
      xml
    end

    def has_ext? # rubocop:disable Metrics/CyclomaticComplexity
      doctype || subdoctype || editorialgroup || ics&.any? || structuredidentifier&.presence?
    end
  end
end
