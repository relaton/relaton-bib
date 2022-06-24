module RelatonBib
  # Version
  class BibliographicItem
    class Version
      include RelatonBib

      # @return [String, nil]
      attr_reader :revision_date, :draft

      # @param revision_date [String, nil]
      # @param draft [String, nil]
      def initialize(revision_date = nil, draft = nil)
        @revision_date = revision_date
        @draft         = draft
      end

      # @param builder [Nokogiri::XML::Builder]
      def to_xml(builder)
        builder.version do
          builder.send(:"revision-date", revision_date) if revision_date
          builder.draft draft if draft
        end
      end

      # @return [Hash]
      def to_hash
        hash = {}
        hash["revision_date"] = revision_date if revision_date
        hash["draft"] = draft if draft
        hash
      end

      # @param prefix [String]
      # @return [String]
      def to_asciibib(prefix = "", count = 1)
        pref = prefix.empty? ? prefix : "#{prefix}."
        out = count > 1 ? "#{prefix}version::\n" : ""
        if revision_date
          out += "#{pref}version.revision_date:: #{revision_date}\n"
        end
        out += "#{pref}version.draft:: #{draft}\n" if draft
        out
      end
    end
  end
end
