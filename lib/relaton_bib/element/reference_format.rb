module RelatonBib
  module Element
    module ReferenceFormat
      TYPES = %w[external inline footnote callout].freeze

      def check_type(type)
        Util.warn "invalid eref type: `#{type}`" unless TYPES.include? type
      end
    end
  end
end
