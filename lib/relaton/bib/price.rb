module Relaton
  module Bib
    class Price
      attr_accessor :content, :currency

      def initialize(**args)
        @content = args[:content]
        @currency = args[:currency]
      end
    end
  end
end
