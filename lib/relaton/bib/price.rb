module Relaton
  module Bib
    class Price
      attr_accessor :amount, :currency

      def initialize(amount:, currency:)
        @amount = amount
        @currency = currency
      end
    end
  end
end
