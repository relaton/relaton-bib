module Relaton
  module Bib
    class DocidentifierType < LocalizedString
      # @return [String, nil]
      attr_accessor :type, :scope # , :sup

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

      def content=(value)
        @content = value.strip
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
          self.content += " (all parts)"
        end
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
