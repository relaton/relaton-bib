module Relaton
  module Bib
    class Logo
      # @return [Relaton::Bib::Image]
      attr_accessor :image

      def initialize(image)
        @image = image
      end
    end
  end
end
