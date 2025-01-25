module Relaton
  module Bib
    # Document identifier.
    class Docidentifier < DocidentifierType
      #
      # Add docidentifier xml element
      #
      # @param opts [Hash]
      # @option opts [Nokogiri::XML::Builder] :builder XML builder
      # @option opts [String] :lang language
      # def to_xml(**opts) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      #   lid = if type == "URN" && opts[:lang]
      #           id.sub %r{(?<=:)(?:\w{2},)*?(#{opts[:lang]})(?:,\w{2})*}, '\1'
      #         else id
      #         end
      #   element = opts[:builder].docidentifier { |b| b.parent.inner_html = lid }
      #   element[:type] = type if type
      #   element[:scope] = scope if scope
      #   element[:primary] = primary if primary
      #   element[:language] = language if language
      #   element[:script] = script if script
      # end

      # @return [Hash]
      # def to_hash # rubocop:disable Metrics/AbcSize
      #   hash = { "id" => id }
      #   hash["type"] = type if type
      #   hash["scope"] = scope if scope
      #   hash["primary"] = primary if primary
      #   hash["language"] = language if language
      #   hash["script"] = script if script
      #   hash
      # end

      # @param prefix [String]
      # @param count [Integer] number of docids
      # @return [String]
      def to_asciibib(prefix = "", count = 1) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize
        pref = prefix.empty? ? prefix : "#{prefix}."
        return "#{pref}docid:: #{content}\n" unless type || scope

        out = count > 1 ? "#{pref}docid::\n" : ""
        out += "#{pref}docid.type:: #{type}\n" if type
        out += "#{pref}docid.scope:: #{scope}\n" if scope
        out += "#{pref}docid.primary:: #{primary}\n" if primary
        out += "#{pref}docid.language:: #{language}\n" if language
        out += "#{pref}docid.script:: #{script}\n" if script
        out + "#{pref}docid.id:: #{content}\n"
      end
    end
  end
end
