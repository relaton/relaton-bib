module Relaton
  module Bib
    # Bibliographic item locality.
    class BibItemLocality
      # @return [String]
      attr_accessor :type, :reference_from, :reference_to

      # @param type [String]
      # @param referenceFrom [String]
      # @param referenceTo [String, nil]
      def initialize(type:, reference_from:, reference_to: nil)
        type_ptrn = %r{section|clause|part|paragraph|chapter|page|title|line|
          whole|table|annex|figure|note|list|example|volume|issue|time|anchor|
          locality:[a-zA-Z0-9_]+}x
        unless type&.match? type_ptrn
          Util.warn "Invalid locality type: `#{type}`"
        end

        @type           = type
        @reference_from = reference_from
        @reference_to   = reference_to
      end

      # @param builder [Nokogiri::XML::Builder]
      # def to_xml(builder)
      #   builder.parent[:type] = type
      #   builder.referenceFrom reference_from # { reference_from.to_xml(builder) }
      #   builder.referenceTo reference_to if reference_to
      # end

      # @return [Hash]
      # def to_hash
      #   hash = { "type" => type, "reference_from" => reference_from }
      #   hash["reference_to"] = reference_to if reference_to
      #   hash
      # end

      # @param prefix [String]
      # @param count [Integeg] number of localities
      # @return [String]
      def to_asciibib(prefix = "", count = 1)
        pref = prefix.empty? ? prefix : "#{prefix}."
        out = count > 1 ? "#{prefix}::\n" : ""
        out += "#{pref}type:: #{type}\n"
        out += "#{pref}reference_from:: #{reference_from}\n"
        out += "#{pref}reference_to:: #{reference_to}\n" if reference_to
        out
      end

      #
      # Render locality as BibTeX.
      #
      # @param [BibTeX::Entry] item BibTeX entry.
      #
      def to_bibtex(item)
        case type
        when "chapter" then item.chapter = reference_from
        when "page"
          value = reference_from
          value += "--#{reference_to}" if reference_to
          item.pages = value
        when "volume" then item.volume = reference_from
        when "issue" then item.number = reference_from
        end
      end
    end

  end
end
