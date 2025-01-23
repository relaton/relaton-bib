module Relaton
  module Bib
    class Phone
      attr_accessor :type, :content

      def initialize(**args)
        @type = args[:type]
        @content = args[:content]
      end
    end
  end
end
