module RelatonBib
  # Version
  class BibliographicItem
    class Version
      # @return [String, NilClass]
      attr_reader :revision_date

      # @return [Array<String>]
      attr_reader :draft

      # @param revision_date [String, NilClass]
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

      # @return [Hash]
      def to_hash
        hash = {}
        hash[:revision_date] = revision_date if revision_date
        hash[:draft] = draft if draft&.any?
        hash
      end
    end
  end
end
