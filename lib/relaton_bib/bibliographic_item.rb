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
require "relaton_bib/biblio_note"
require "relaton_bib/biblio_version"
require "relaton_bib/workers_pool"
require "relaton_bib/hash_converter"
require "relaton_bib/place"

module RelatonBib
  # Bibliographic item
  class BibliographicItem
    include RelatonBib

    TYPES = %W[article book booklet conference manual proceedings presentation
               thesis techreport standard unpublished map electronic\sresource
               audiovisual film video broadcast graphic_work music patent
               inbook incollection inproceedings journal].freeze

    # @return [String, NilClass]
    attr_reader :id

    # @return [Array<RelatonBib::TypedTitleString>]
    attr_reader :title

    # @return [Array<RelatonBib::TypedUri>]
    attr_reader :link

    # @return [String, NilClass]
    attr_reader :type

    # @return [Array<RelatonBib::DocumentIdentifier>]
    attr_reader :docidentifier

    # @return [String, NilClass] docnumber
    attr_reader :docnumber

    # @return [Array<RelatonBib::BibliographicDate>]
    attr_reader :date

    # @return [Array<RelatonBib::ContributionInfo>]
    attr_reader :contributor

    # @return [String, NillClass]
    attr_reader :edition

    # @return [RelatonBib::BibliongraphicItem::Version, NilClass]
    attr_reader :version

    # @return [Array<RelatonBib::BiblioNote>]
    attr_reader :biblionote

    # @return [Array<String>] language Iso639 code
    attr_reader :language

    # @return [Array<String>] script Iso15924 code
    attr_reader :script

    # @return [RelatonBib::FormattedRef, NilClass]
    attr_reader :formattedref

    # @!attribute [r] abstract
    #   @return [Array<RelatonBib::FormattedString>]

    # @return [RelatonBib::DocumentStatus, NilClass]
    attr_reader :status

    # @return [RelatonBib::CopyrightAssociation, NilClass]
    attr_reader :copyright

    # @return [RelatonBib::DocRelationCollection]
    attr_reader :relation

    # @return [Array<RelatonBib::Series>]
    attr_reader :series

    # @return [RelatonBib::Medium, NilClass]
    attr_reader :medium

    # @return [Array<RelatonBib::Place>]
    attr_reader :place

    # @return [Array<RelatonBib::BibItemLocality>]
    attr_reader :extent

    # @return [Array<Strig>]
    attr_reader :accesslocation

    # @return [Relaton::Classification, NilClass]
    attr_reader :classification

    # @return [RelatonBib:Validity, NilClass]
    attr_reader :validity

    # @return [Date]
    attr_reader :fetched

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    # @param id [String, NilClass]
    # @param title [Array<RelatonBib::TypedTitleString>]
    # @param formattedref [RelatonBib::FormattedRef, NilClass]
    # @param type [String, NilClass]
    # @param docid [Array<RelatonBib::DocumentIdentifier>]
    # @param docnumber [String, NilClass]
    # @param language [Arra<String>]
    # @param script [Array<String>]
    # @param docstatus [RelatonBib::DocumentStatus, NilClass]
    # @param edition [String, NilClass]
    # @param version [RelatonBib::BibliographicItem::Version, NilClass]
    # @param biblionote [Array<RelatonBib::BiblioNote>]
    # @param series [Array<RelatonBib::Series>]
    # @param medium [RelatonBib::Medium, NilClas]
    # @param place [Array<String, RelatonBib::Place>]
    # @param extent [Array<Relaton::BibItemLocality>]
    # @param accesslocation [Array<String>]
    # @param classification [RelatonBib::Classification, NilClass]
    # @param validity [RelatonBib:Validity, NilClass]
    # @param fetched [Date, NilClass] default nil
    #
    # @param copyright [Hash, RelatonBib::CopyrightAssociation, NilClass]
    # @option copyright [Hash, RelatonBib::ContributionInfo] :owner
    # @option copyright [String] :form
    # @option copyright [String, NilClass] :to
    #
    # @param date [Array<Hash>]
    # @option date [String] :type
    # @option date [String] :from
    # @option date [String] :to
    #
    # @param contributor [Array<Hash>]
    # @option contributor [RealtonBib::Organization, RelatonBib::Person]
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
    # @option abstract [String] :type
    #
    # @param relation [Array<Hash>]
    # @option relation [String] :type
    # @option relation [RelatonBib::BibliographicItem, RelatonIso::IsoBibliographicItem] :bibitem
    # @option relation [Array<RelatonBib::BibItemLocality>] :bib_locality
    #
    # @param link [Array<Hash, RelatonBib::TypedUri>]
    # @option link [String] :type
    # @option link [String] :content
    def initialize(**args)
      if args[:type] && !TYPES.include?(args[:type])
        warn %{Document type "#{args[:type]}" is invalid.}
      end

      @title = (args[:title] || []).map do |t|
        t.is_a?(Hash) ? TypedTitleString.new(t) : t
      end

      @date = (args[:date] || []).map do |d|
        d.is_a?(Hash) ? BibliographicDate.new(d) : d
      end

      @contributor = (args[:contributor] || []).map do |c|
        if c.is_a? Hash
          e = c[:entity].is_a?(Hash) ? Organization.new(c[:entity]) : c[:entity]
          ContributionInfo.new(entity: e, role: c[:role])
        else c
        end
      end

      @abstract = (args[:abstract] || []).map do |a|
        a.is_a?(Hash) ? FormattedString.new(a) : a
      end

      if args[:copyright]
        @copyright = if args[:copyright].is_a?(Hash)
                       CopyrightAssociation.new args[:copyright]
                     else args[:copyright]
                     end
      end

      @docidentifier  = args[:docid] || []
      @formattedref   = args[:formattedref] if title.empty?
      @id             = args[:id] || makeid(nil, false)
      @type           = args[:type]
      @docnumber      = args[:docnumber]
      @edition        = args[:edition]
      @version        = args[:version]
      @biblionote     = args.fetch :biblionote, []
      @language       = args.fetch :language, []
      @script         = args.fetch :script, []
      @status         = args[:docstatus]
      @relation       = DocRelationCollection.new(args[:relation] || [])
      @link           = args.fetch(:link, []).map { |s| s.is_a?(Hash) ? TypedUri.new(s) : s }
      @series         = args.fetch :series, []
      @medium         = args[:medium]
      @place          = args.fetch(:place, []).map { |pl| pl.is_a?(String) ? Place.new(name: pl) : pl }
      @extent         = args[:extent] || []
      @accesslocation = args.fetch :accesslocation, []
      @classification = args[:classification]
      @validity       = args[:validity]
      @fetched        = args.fetch :fetched, nil # , Date.today # we should pass the fetched arg from scrappers
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    # @param lang [String] language code Iso639
    # @return [RelatonBib::FormattedString, Array<RelatonBib::FormattedString>]
    def abstract(lang: nil)
      if lang
        @abstract.detect { |a| a.language.include? lang }
      else
        @abstract
      end
    end

    def makeid(id, attribute)
      return nil if attribute && !@id_attribute

      id ||= @docidentifier.reject { |i| i.type == "DOI" }[0]
      return unless id

      # contribs = publishers.map { |p| p&.entity&.abbreviation }.join '/'
      # idstr = "#{contribs}#{delim}#{id.project_number}"
      # idstr = id.project_number.to_s
      idstr = id.id.gsub(/:/, "-").gsub /\s/, ""
      # if id.part_number&.size&.positive? then idstr += "-#{id.part_number}"
      idstr.strip
    end

    # @return [String]
    def shortref(identifier, **opts)
      pubdate = date.select { |d| d.type == "published" }
      year = if opts[:no_year] || pubdate.empty? then ""
             else ":" + pubdate&.first&.on&.year.to_s
             end
      year += ": All Parts" if opts[:all_parts] || @all_parts

      "#{makeid(identifier, false)}#{year}"
    end

    # @param builder [Nokogiri::XML::Builder, NillClass] (nil)
    # @return [String]
    def to_xml(builder = nil, **opts, &block)
      if builder
        render_xml builder, **opts, &block
      else
        Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
          render_xml xml, **opts, &block
        end.doc.root.to_xml
      end
    end

    # @return [Hash]
    def to_hash
      hash = {}
      hash["id"] = id if id
      hash["title"] = single_element_array(title) if title&.any?
      hash["link"] = single_element_array(link) if link&.any?
      hash["type"] = type if type
      hash["docid"] = single_element_array(docidentifier) if docidentifier&.any?
      hash["docnumber"] = docnumber if docnumber
      hash["date"] = single_element_array(date) if date&.any?
      hash["contributor"] = single_element_array(contributor) if contributor&.any?
      hash["edition"] = edition if edition
      hash["version"] = version.to_hash if version
      hash["revdate"] = revdate if revdate
      hash["biblionote"] = single_element_array(biblionote) if biblionote&.any?
      hash["language"] = single_element_array(language) if language&.any?
      hash["script"] = single_element_array(script) if script&.any?
      hash["formattedref"] = formattedref.to_hash if formattedref
      hash["abstract"] = single_element_array(abstract) if abstract&.any?
      hash["docstatus"] = status.to_hash if status
      hash["copyright"] = copyright.to_hash if copyright
      hash["relation"] = single_element_array(relation) if relation&.any?
      hash["series"] = single_element_array(series) if series&.any?
      hash["medium"] = medium.to_hash if medium
      hash["place"] = single_element_array(place) if place&.any?
      hash["extent"] = single_element_array(extent) if extent&.any?
      hash["accesslocation"] = single_element_array(accesslocation) if accesslocation&.any?
      hash["classification"] = classification.to_hash if classification
      hash["validity"] = validity.to_hash if validity
      hash["fetched"] = fetched.to_s if fetched
      hash
    end

    # If revision_date exists then returns it else returns published date or nil
    # @return [String, NilClass]
    def revdate
      @revdate ||= if version&.revision_date
                     version.revision_date
                   else
                     date.detect { |d| d.type == "published" }&.on&.to_s
                   end
    end

    private

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    # rubocop:disable Style/NestedParenthesizedCalls, Metrics/BlockLength

    # @param builder [Nokogiri::XML::Builder]
    # @return [String]
    def render_xml(builder, **opts)
      root = opts[:bibdata] ? :bibdata : :bibitem
      xml = builder.send(root) do
        builder.fetched fetched if fetched
        title.each { |t| builder.title { t.to_xml builder } }
        formattedref&.to_xml builder
        link.each { |s| s.to_xml builder }
        docidentifier.each { |di| di.to_xml builder }
        builder.docnumber docnumber if docnumber
        date.each { |d| d.to_xml builder, **opts }
        contributor.each do |c|
          builder.contributor do
            c.role.each { |r| r.to_xml builder }
            c.to_xml builder
          end
        end
        builder.edition edition if edition
        version&.to_xml builder
        biblionote.each { |n| n.to_xml builder }
        language.each { |l| builder.language l }
        script.each { |s| builder.script s }
        abstract.each { |a| builder.abstract { a.to_xml(builder) } }
        status&.to_xml builder
        copyright&.to_xml builder
        relation.each { |r| r.to_xml builder, **opts }
        series.each { |s| s.to_xml builder }
        medium&.to_xml builder
        place.each { |pl| pl.to_xml builder }
        extent.each { |e| builder.extent { e.to_xml builder } }
        accesslocation.each { |al| builder.accesslocation al }
        classification&.to_xml builder
        validity&.to_xml builder
        if block_given?
          yield builder
        end
      end
      xml[:id] = id if id && !opts[:bibdata] && !opts[:embedded]
      xml[:type] = type if type
      xml
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    # rubocop:enable Style/NestedParenthesizedCalls, Metrics/BlockLength
  end
end
