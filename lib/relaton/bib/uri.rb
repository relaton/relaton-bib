module Relaton
  module Bib
    class Uri < LocalizedStringAttrs
      attr_accessor :type, :content

      def initialize(**args)
        super
        @type = args[:type]
        @content = args[:content]
      end
    end
  end
end
