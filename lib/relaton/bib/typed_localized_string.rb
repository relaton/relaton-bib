module Relaton
  module Bib
    class TypedLocalizedString < LocalizedString
      attr_accessor :type

      def initialize(**args)
        super
        @type = args[:type]
      end
    end
  end
end
