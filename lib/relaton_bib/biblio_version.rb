module RelatonBib
  # Version
  class BibliographicItem
    class Version
      include RelatonBib

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
          builder.send("revision-date", revision_date) if revision_date
          draft.each { |d| builder.draft d }
        end
      end

      # @return [Hash]
      def to_hash
        hash = {}
        hash["revision_date"] = revision_date if revision_date
        hash["draft"] = single_element_array(draft) if draft&.any?
        hash
      end

      # @param prefix [String]
      # @return [String]
      def to_asciibib(prefix = "")
        pref = prefix.empty? ? prefix : prefix + "."
        out = ""
        if revision_date
          out += "#{pref}version.revision_date:: #{revision_date}\n"
        end
        draft&.each { |d| out += "#{pref}version.draft:: #{d}\n" }
        out
      end
    end
  end
end
