module RelatonBib
  # Version
  class << self
    def version_hash_to_bib(ret)
      return unless ret[:version]
      ret[:version][:draft] = array(ret[:version][:draft])
      ret[:version] and ret[:version] = BibliographicItem::Version.new(
          ret[:version][:revision_date], ret[:version][:draft])
    end
  end

  class BibliographicItem
    class Version
      # @return [String]
      attr_reader :revision_date

      # @return [Array<String>]
      attr_reader :draft

      # @param revision_date [String]
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
  end
end
