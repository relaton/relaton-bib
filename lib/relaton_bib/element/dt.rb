module RelatonBib
  module Element
    class Dt
      include Base
      def to_xml(builder)
        builder.dt { |b| super b }
      end
    end
  end
end
