module RelatonBib
  class Source < TypedUri
    def to_xml(builder)
      builder.uri { |b| super b }
    end

    def to_asciibib(prefix, count = 1)
      pref = prefix.empty? ? "link" : "#{prefix}.link"
      super pref, count
    end
  end
end
