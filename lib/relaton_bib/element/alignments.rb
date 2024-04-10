module RelatonBib
  module Element
    module Alignments
      ALIGNMENTS = %w[left right center justify].freeze

      def check_alignment(align)
        if align && !ALIGNMENTS.include?(align)
          Util.warn "Invalid alignment: #{align}"
        end
      end
    end
  end
end
