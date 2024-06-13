module RelatonBib
  module Element
    class Tname
      include Base

      def to_xml(builder)
        builder.name { |b| super(b) }
      end
    end
  end
end
