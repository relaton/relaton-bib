module RelatonBib
  module Element
    class Source < RelatonBib::TypedUri
      def to_xml(builder)
        builder.source { |b| super b }
      end

      def to_asciibib(prefix = "", count = 1)
        pref = prefix.empty? ? "source" : "#{prefix}.source"
        super pref, count
      end
    end
  end
end
