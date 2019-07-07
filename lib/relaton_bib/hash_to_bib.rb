module RelatonBib
  class << self
    def hash_to_bib(args, nested = false)
      return nil unless args.is_a?(Hash)
      ret = Marshal.load(Marshal.dump(symbolize(args))) # deep copy
      timestamp_hash(ret) unless nested
      title_hash_to_bib(ret)
      link_hash_to_bib(ret)
      language_hash_to_bib(ret)
      script_hash_to_bib(ret)
      dates_hash_to_bib(ret)
      docid_hash_to_bib(ret)
      version_hash_to_bib(ret)
      biblionote_hash_to_bib(ret)
      abstract_hash_to_bib(ret)
      formattedref_hash_to_bib(ret)
      docstatus_hash_to_bib(ret)
      contributors_hash_to_bib(ret)
      relations_hash_to_bib(ret)
      series_hash_to_bib(ret)
      medium_hash_to_bib(ret)
      place_hash_to_bib(ret)
      extent_hash_to_bib(ret)
      accesslocation_hash_to_bib(ret)
      classification_hash_to_bib(ret)
      validity_hash_to_bib(ret)
      ret
    end

    def timestamp_hash(ret)
      ret[:fetched] ||= Date.today.to_s
    end

    def symbolize(obj)
      obj.is_a? Hash and
        return obj.inject({}){|memo,(k,v)| memo[k.to_sym] =  symbolize(v); memo}
      obj.is_a? Array and
        return obj.inject([]){|memo,v    | memo           << symbolize(v); memo}
      return obj
    end

    def array(a)
      return [] unless a
      return [a] unless a.is_a?(Array)
      a
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
