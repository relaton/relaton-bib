# Monkey patch to fix the issue with month quotes in BibTeX
module BibTeX
  class Value
    def to_s(options = {}) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      if options.key?(:filter)
        opts = options.reject { |k,| k == :filter || (k == :quotes && (!atomic? || symbol?)) }
        return convert(options[:filter]).to_s(opts)
      end

      return value.to_s unless options.key?(:quotes) && atomic?

      q = Array(options[:quotes])
      [q[0], value, q[-1]].compact.join
    end
  end
end

module Relaton
  module Bib
    module Renderer
      # BibTeX builder.
      class BibtexBuilder
        include Core::ArrayWrapper

        ATTRS = %i[
          type id title author editor booktitle series number edition contributor
          date address note relation extent classification keyword docidentifier
          timestamp link
        ].freeze

        #
        # Build BibTeX bibliography.
        #
        # @param bib [Relaton::Bib::Item]
        # @param bibtex [BibTeX::Bibliography, nil] BibTeX bibliography
        #
        # @return [BibTeX::Bibliography] BibTeX bibliography
        #
        def self.build(bib, bibtex = nil)
          new(bib).build bibtex
        end

        #
        # Initialize BibTeX builder.
        #
        # @param bib [Relaton::Bib::Item]
        def initialize(bib)
          @bib = bib
        end

        #
        # Build BibTeX bibliography.
        #
        # @param bibtex [BibTeX::Bibliography, nil] BibTeX bibliography
        #
        # @return [BibTeX::Bibliography] BibTeX bibliography
        #
        def build(bibtex = nil)
          @item = BibTeX::Entry.new
          ATTRS.each { |a| send("add_#{a}") }
          bibtex ||= BibTeX::Bibliography.new
          bibtex << @item
          bibtex
        end

        private

        #
        # Add type to BibTeX item
        #
        def add_type
          @item.type = bibtex_type
        end

        # @return [String] BibTeX type
        def bibtex_type
          case @bib.type
          when "standard", nil then "misc"
          else @bib.type
          end
        end

        #
        # Add ID to BibTeX item
        #
        def add_id
          @item.key = @bib.id
        end

        #
        # Add title to BibTeX item
        #
        def add_title
          return unless @bib.title&.any?

          title = @bib.title.find { |t| t.type == "main" } || @bib.title.first
          return unless title

          @item .title = title.content
        end

        #
        # Add booktitle to BibTeX item
        #
        def add_booktitle # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity
          return unless @bib.relation&.any?

          included_in = @bib.relation.detect { |r| r.type == "includedIn" }
          return unless included_in && included_in.bibitem.title&.any?

          @item.booktitle = included_in.bibitem.title.first.content
        end

        #
        # Add author to BibTeX item
        #
        def add_author
          add_author_editor "author"
        end

        #
        # Add editor to BibTeX item
        #
        def add_editor
          add_author_editor "editor"
        end

        #
        # Add author or editor to BibTeX item
        #
        # @param [String] type "author" or "editor"
        #
        def add_author_editor(type) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
          retur unless @bib.contributor&.any?

          contribs = @bib.contributor.select do |c|
            c.person && c.role.any? { |e| e.type == type }
          end.map &:person

          return unless contribs.any?

          @item.send "#{type}=", concat_names(contribs)
        end

        #
        # Concatenate names of contributors
        #
        # @param [Array<Relaton::Bib::Person>] contribs contributors
        #
        # @return [String] concatenated names
        #
        def concat_names(contribs)
          contribs.map do |p|
            if p.name.surname
              "#{p.name.surname.content}, #{p.name.forename.map(&:content).join(' ')}"
            else
              p.name.completename.content
            end
          end.join(" and ")
        end

        #
        # Add series to BibTeX item
        #
        def add_series # rubocop:disable Metrics/AbcSize
          return unless @bib.series

          @bib.series.each do |s|
            case s.type
            when "journal"
              @item.journal = s.title.first.content
              @item.number = s.number if s.number
            when nil then @item.series = s.title.first.content
            end
          end
        end

        #
        # Add number to BibTeX item
        #
        def add_number
          return unless %w[techreport manual].include? @bib.type

          did = @bib.docidentifier.detect { |i| i.primary == true }
          did ||= @bib.docidentifier.first
          @item.number = did.content if did
        end

        #
        # Add edition to BibTeX item
        #
        def add_edition
          @item.edition = @bib.edition.content if @bib.edition
        end

        #
        # Add contributor to BibTeX item
        #
        def add_contributor # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
          @bib.contributor.each do |c|
            rls = c.role.map(&:type)
            if rls.include?("publisher") then @item.publisher = c.organization.name.first.content
            elsif rls.include?("distributor")
              case @bib.type
              when "techreport" then @item.institution = c.organization.name.first.content
              when "inproceedings", "conference", "manual", "proceedings"
                @item.organization = c.organization.name.first.content
              when "mastersthesis", "phdthesis" then @item.school = c.organization.name.first.content
              end
            end
          end
        end

        #
        # Add date to BibTeX item
        #
        def add_date
          array(@bib.date).each do |d|
            case d.type
            when "published"
              year, month, = d.at.split("-")
              @item.year = year
              @item.month = month if month
            when "accessed" then @item.urldate = d.at.to_s
            end
          end
        end

        #
        # Add address to BibTeX item
        #
        def add_address # rubocop:disable Metrics/AbcSize
          return unless @bib.place&.any?

          reg = @bib.place[0].region[0].content if @bib.place[0].region.any?
          addr = [@bib.place[0].formatted_place, @bib.place[0].city, reg]
          @item.address = addr.compact.join(", ")
        end

        #
        # Add note to BibTeX item
        #
        def add_note # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
          array(@bib.note).each do |n|
            case n.type
            when "annote" then @item.annote = n.content
            when "howpublished" then @item.howpublished = n.content
            when "comment" then @item.comment = n.content
            when "tableOfContents" then @item.content = n.content
            when nil then @item.note = n.content
            end
          end
        end

        #
        # Add relation to BibTeX item
        #
        def add_relation # rubocop:disable Metrics/AbcSize
          rel = array(@bib.relation).detect { |r| r.type == "partOf" }
          if rel && rel.bibitem.title&.any?
            title_main = rel.bibitem.title.detect { |t| t.type == "main" }
            @item.booktitle = title_main.content
          end
        end

        #
        # Add extent to BibTeX item
        #
        def add_extent # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
          @bib.extent&.each do |extent|
            extent.locality&.each { |loc| add_locality loc } ||
              extent.locality_stack&.each { |locs| add_locality_stack locs }
          end
        end

        def add_locality_stack(locs)
          return unless locs

          locs.locality.each { |loc| add_locality loc }
        end

        def add_locality(loc)
          case loc.type
          when "chapter" then @item.chapter = loc.reference_from
          when "page"
            value = [loc.reference_from]
            value << loc.reference_to if loc.reference_to
            @item.pages = value.join("--")
          when "volume" then @item.volume = loc.reference_from
          when "issue" then @item.issue = loc.reference_from
          end
        end

        #
        # Add classification to BibTeX item
        #
        def add_classification
          @bib.classification&.each do |c|
            case c.type
            when "type" then @item["type"] = c.content
            when "mendeley" then @item["mendeley-tags"] = c.content
            end
          end
        end

        #
        # Add keywords to BibTeX item
        #
        def add_keyword
          if @bib.keyword&.any?
            @item.keywords = @bib.keyword.reduce([]) { |m, kw| m + kw.taxon.map(&:content) }.join(", ")
          end
        end

        #
        # Add docidentifier to BibTeX item
        #
        def add_docidentifier
          @bib.docidentifier&.each do |i|
            case i.type
            when "isbn" then @item.isbn = i.content
            when "lccn" then @item.lccn = i.content
            when "issn" then @item.issn = i.content
            end
          end
        end

        #
        # Add identifier to BibTeX item
        #
        def add_timestamp
          @item.timestamp = @bib.fetched.to_s if @bib.fetched
        end

        #
        # Add link to BibTeX item
        #
        def add_link # rubocop:disable Metrics/CyclomaticComplexity
          @bib.source&.each do |l|
            case l.type&.downcase
            when "doi" then @item.doi = l.content
            when "file" then @item.file2 = l.content
            when "src" then @item.url = l.content
            end
          end
        end
      end
    end
  end
end
