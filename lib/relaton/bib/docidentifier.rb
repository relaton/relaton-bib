module Relaton
  module Bib
    # Document identifier.
    class Docidentifier < Relaton::Bib::LocalizedString
      # @return [String, nil]
      attr_accessor :type, :scope, :sup

      # @param type [Boolean, nil]
      attr_accessor :primary

      # @param content [Relaton::Bib::LoclizedString]
      # @param type [String, nil]
      # @param scope [String, nil]
      # @param primary [Bolean, nil]
      # @param language [String, nil]
      # @param script [String, nil]
      # @param locale [String, nil]
      def initialize(**args)
        super
        @type     = args[:type]
        @scope    = args[:scope]
        @primary  = args[:primary]
      end

      # in docid manipulations, assume ISO as the default: id-part:year
      def remove_part
        case @type
        when "Chinese Standard" then content.sub!(/\.\d+/, "")
        when "URN" then remove_urn_part
        else content.sub!(/-[^:]+/, "")
        end
      end

      def remove_date
        case type
        when "Chinese Standard" then content.sub!(/-[12]\d\d\d/, "")
        when "URN"
          content.sub!(/^(urn:iec:std:[^:]+:[^:]+:)[^:]*/, '\1')
        else content.sub!(/:[12]\d\d\d/, "")
        end
      end

      def all_parts
        if type == "URN"
          content.sub!(%r{^(urn:iec:std(?::[^:]*){4}).*}, '\1:ser')
        else
          content += " (all parts)"
        end
      end

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

      private

      def remove_urn_part # rubocop:disable Metrics/MethodLength
        content.sub!(%r{^
          (urn:iso:std:[^:]+ # ISO prefix and originator
            (?::(?:data|guide|isp|iwa|pas|r|tr|ts|tta)) # type
            ?:\d+) # docnumber
          (?::-[^:]+)? # partnumber
          (?::(draft|cancelled|stage-[^:]+))? # status
          (?::ed-\d+)?(?::v[^:]+)? # edition and version
          (?::\w{2}(?:,\w{2})*)? # langauge
        }x, '\1') # remove partnumber, status, version, and language
        content.sub!(%r{^
          (urn:iec:std:[^:]+ # IEC prefix and originator
            :\d+) # docnumber
          (?:-[^:]+)? # partnumber
        }x, '\1') # remove partnumber
      end
    end
  end
end
