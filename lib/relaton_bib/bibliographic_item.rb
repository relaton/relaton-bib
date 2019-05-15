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


module RelatonBib
  # Bibliographic item
  class BibliographicItem
    class Version
      # @return [String]
      attr_reader :revision_date

      # @return [Array<String>]
      attr_reader :draft

      # @oaram revision_date [String]
      # @param draft [Array<String>]
      def initialize(revision_date = nil, draft = [])
        @revision_date = revision_date
        @draft         = draft
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.version do
          builder.revision_date revision_date if revision_date
          draft.each { |d| builder.draft d }
        end
      end
    end

    TYPES = %W[article book booklet conference manual proceedings presentation
               thesis techreport standard unpublished map electronic\sresource
               audiovisual film video broadcast graphic_work music patent
               inbook incollection inproceedings journal].freeze

    # @return [String]
    attr_reader :id

    # @return [Array<RelatonBib::TypedTitleString>]
    attr_reader :title

    # @return [Array<RelatonBib::TypedUri>]
    attr_reader :link

    # @return [String]
    attr_reader :type

    # @return [Array<RelatonBib::DocumentIdentifier>]
    attr_reader :docidentifier

    # @return [String] docnumber
    attr_reader :docnumber

    # @return [Array<RelatonBib::BibliographicDate>]
    attr_reader :dates

    # @return [Array<RelatonBib::ContributionInfo>]
    attr_reader :contributors

    # @return [String, NillClass]
    attr_reader :edition

    # @return [RelatonBib::BibliongraphicItem::Version]
    attr_reader :version

    # @return [Array<RelatonBib::BiblioNote>, NilClass]
    attr_reader :biblionote

    # @return [Array<String>] language Iso639 code
    attr_reader :language

    # @return [Array<String>] script Iso15924 code
    attr_reader :script

    # @return [RelatonBib::FormattedRef]
    attr_reader :formattedref

    # @!attribute [r] abstract
    #   @return [Array<RelatonBib::FormattedString>]

    # @return [RelatonBib::DocumentStatus]
    attr_reader :status

    # @return [RelatonBib::CopyrightAssociation]
    attr_reader :copyright

    # @return [RelatonBib::DocRelationCollection]
    attr_reader :relations

    # @return [Array<RelatonBib::Series>]
    attr_reader :series

    # @return [RelatonBib::Medium, NilClass]
    attr_reader :medium

    # @return [Array<String>]
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
    # @param place [Array<String>]
    # @param extent [Array<Relaton::BibItemLocality>]
    # @param accesslocation [Array<String>]
    # @param classification [RelatonBib::Classification, NilClass]
    # @param validity [RelatonBib:Validity, NilClass]
    # @param fetched [Date, NilClass] default nil
    #
    # @param dates [Array<Hash>]
    # @option dates [String] :type
    # @option dates [String] :from
    # @option dates [String] :to
    #
    # @param contributors [Array<Hash>]
    # @option contributors [RealtonBib::Organization, RelatonBib::Person]
    # @option contributors [String] :type
    # @option contributors [String] :from
    # @option contributirs [String] :to
    # @option contributors [String] :abbreviation
    # @option contributors [Array<Array<String,Array<String>>>] :roles
    #
    # @param abstract [Array<Hash>]
    # @option abstract [String] :content
    # @option abstract [String] :language
    # @option abstract [String] :script
    # @option abstract [String] :type
    #
    # @param relations [Array<Hash>]
    # @option relations [String] :type
    # @option relations [RelatonBib::BibliographicItem] :bibitem
    # @option relations [Array<RelatonBib::BibItemLocality>] :bib_locality
    def initialize(**args)
      if args[:type] && !TYPES.include?(args[:type])
        raise ArgumentError, %{Type "#{args[:type]}" is invalid.}
      end

      @title = (args[:titles] || []).map do |t|
        t.is_a?(Hash) ? TypedTitleString.new(t) : t
      end

      @dates = (args[:dates] || []).map do |d|
        d.is_a?(Hash) ? BibliographicDate.new(d) : d
      end

      @contributors = (args[:contributors] || []).map do |c|
        if c.is_a? Hash
          e = c[:entity].is_a?(Hash) ? Organization.new(c[:entity]) : c[:entity]
          ContributionInfo.new(entity: e, role: c[:roles])
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

      @id             = args[:id]
      @formattedref   = args[:formattedref] if title.empty?
      @type           = args[:type]
      @docidentifier  = args[:docid] || []
      @docnumber      = args[:docnumber]
      @edition        = args[:edition]
      @version        = args[:version]
      @biblionote     = args.fetch :biblionote, []
      @language       = args.fetch :language, []
      @script         = args.fetch :script, []
      @status         = args[:docstatus]
      @relations      = DocRelationCollection.new(args[:relations] || [])
      @link           = args.fetch(:link, []).map { |s| s.is_a?(Hash) ? TypedUri.new(s) : s }
      @series         = args.fetch :series, []
      @medium         = args[:medium]
      @place          = args.fetch(:place, [])
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
      # contribs = publishers.map { |p| p&.entity&.abbreviation }.join '/'
      # idstr = "#{contribs}#{delim}#{id.project_number}"
      # idstr = id.project_number.to_s
      idstr = id.id.gsub(/:/, "-")
      # if id.part_number&.size&.positive? then idstr += "-#{id.part_number}"
      idstr.strip
    end

    # @return [String]
    def shortref(identifier, **opts)
      pubdate = dates.select { |d| d.type == "published" }
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

    private

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    # rubocop:disable Style/NestedParenthesizedCalls, Metrics/BlockLength

    # @param builder [Nokogiri::XML::Builder]
    # @return [String]
    def render_xml(builder, **opts)
      xml = builder.send(opts.fetch :root, :bibitem) do
        builder.fetched fetched if fetched
        title.each { |t| builder.title { t.to_xml builder } }
        formattedref&.to_xml builder
        link.each { |s| s.to_xml builder }
        docidentifier.each { |di| di.to_xml builder }
        builder.docnumber docnumber if docnumber
        dates.each { |d| d.to_xml builder, **opts }
        contributors.each do |c|
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
        relations.each { |r| r.to_xml builder, **opts }
        series.each { |s| s.to_xml builder }
        medium&.to_xml builder
        place.each { |pl| builder.place pl }
        extent.each { |e| e.to_xml builder }
        accesslocation.each { |al| builder.accesslocation al }
        classification&.to_xml builder
        validity&.to_xml builder
        if block_given?
          yield builder
        end
      end
      xml[:id] = id if id
      xml[:type] = type if type
      xml
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    # rubocop:enable Style/NestedParenthesizedCalls, Metrics/BlockLength
  end
end
