module Relaton
  module Bib
    class Depiction
      #
      # @param [String] scope Description of what is being depicted
      # @param [Array<Relaton::Bib::Image>] image A visual depiction of the bibliographic item
      #
      # @return [Relaton::Bib::Depiction]
      #
      def initialize(scope: nil, image: [])
        @scope = scope
        @image = image
      end
    end
  end
end
