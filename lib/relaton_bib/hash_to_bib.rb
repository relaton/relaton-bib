module RelatonBib
  class << self
    def hash_to_bib(args)
      ret = Marshal.load(Marshal.dump(symbolize(args))) # deep copy
      docid_hash_to_bib(ret)
      version_hash_to_bib(ret)
      biblionote_hash_to_bib(ret)
      formattedref_hash_to_bib(ret)
      docstatus_hash_to_bib(ret)
      contributors_hash_to_bib(ret)
      relations_hash_to_bib(ret)
      series_hash_to_bib(ret)
      medium_hash_to_bib(ret)
      extent_hash_to_bib(ret)
      classification_hash_to_bib(ret)
      validity_hash_to_bib(ret)
      ret
    end

    def symbolize(obj)
      obj.is_a? Hash and
        return obj.inject({}){|memo,(k,v)| memo[k.to_sym] =  symbolize(v); memo}
      obj.is_a? Array and
        return obj.inject([]){|memo,v    | memo           << symbolize(v); memo}
      return obj
    end

    def localname(f, c)
      return nil if f.nil?
      f.is_a?(Hash) and lang = f[:language] 
      lang ||= c[:name][:language] 
      f.is_a?(Hash) and script = f[:script] 
      script ||= c[:name][:script]
      f.is_a?(Hash) ?
        RelatonBib::LocalizedString.new(f[:content], lang, script) :
        RelatonBib::LocalizedString.new(f, lang, script)
    end

    def localizedstring(f)
      f.is_a?(Hash) ?
        RelatonBib::LocalizedString.new(f[:content], f[:language], f[:script]) :
        RelatonBib::LocalizedString.new(f)
    end

    def formattedref(f)
      f.is_a?(Hash) ? RelatonBib::FormattedRef.new(f) :
        RelatonBib::FormattedRef.new(content: f)
    end
  end
end
