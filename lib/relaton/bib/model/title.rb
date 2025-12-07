module Relaton
  module Bib
    class Title < LocalizedMarkedUpString
      attribute :type, :string
      attribute :format, :string # @DEPRECATED

      xml do
        map_attribute "type", to: :type
        map_attribute "format", to: :format
      end

      key_value do
        map "type", to: :type
        map "format", to: :format
      end

      class << self
        def from_string(title, lang = nil, script = nil)
          types = %w[title-intro title-main title-part]
          ttls = split_title(title)
          tts = ttls.map.with_index do |p, i|
            next unless p

            new type: types[i], content: p, language: lang, script: script
          end.compact
          tts << new(type: "main", content: ttls.compact.join(" - "), language: lang, script: script)
          tts
        end

        private

        # @param title [String]
        # @return [Array<String, nil>]
        def split_title(title)
          ttls = title.sub(/\w\.Imp\s?\d+\u00A0:\u00A0/, "").split " - "
          case ttls.size
          when 0, 1 then [nil, ttls.first.to_s, nil]
          else intro_or_part ttls
          end
        end

        # @param ttls [Array<String>]
        # @return [Array<String, nil>]
        def intro_or_part(ttls)
          if /^(Part|Partie) \d+:/.match? ttls[1]
            [nil, ttls[0], ttls[1..].join(" -- ")]
          else
            parts = ttls.slice(2..-1)
            part = parts.join " -- " if parts.any?
            [ttls[0], ttls[1], part]
          end
        end
      end
    end
  end
end
