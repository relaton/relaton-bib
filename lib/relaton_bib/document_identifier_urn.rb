module RelatonBib
  class DocumentIdentifierUrn
    include RelatonBib::DocumentIdentifierBase

    #
    # Returns the identifier as string.
    #
    # @param [String, nil] language <description>
    #
    # @return [String] identifier
    #
    def id(language = nil)
      if language
        @id.sub %r{(?<=:)(?:\w{2},)*?(#{language})(?:,\w{2})*}, '\1'
      else
        @id
      end
    end

    def remove_part
      @id.sub!(%r{^
        (urn:iso:std:[^:]+ # ISO prefix and originator
          (?::(?:data|guide|isp|iwa|pas|r|tr|ts|tta)) # type
          ?:\d+) # docnumber
        (?::-[^:]+)? # partnumber
        (?::(draft|cancelled|stage-[^:]+))? # status
        (?::ed-\d+)?(?::v[^:]+)? # edition and version
        (?::\w{2}(?:,\w{2})*)? # langauge
      }x, '\1') # remove partnumber, status, version, and language
      @id.sub!(%r{^
        (urn:iec:std:[^:]+ # IEC prefix and originator
          :\d+) # docnumber
        (?:-[^:]+)? # partnumber
      }x, '\1') # remove partnumber
    end

    def remove_date
      @id.sub!(/^(urn:iec:std:[^:]+:[^:]+:)[^:]*/, '\1')
    end

    def all_parts
      @id.sub!(%r{^(urn:iec:std(?::[^:]*){4}).*}, '\1:ser')
    end
  end
end
