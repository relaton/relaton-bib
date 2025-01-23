module Relaton
  module Bib
    class LocalizedStringAttrs
      attr_accessor :language, :script, :locale

      def initialize(**args)
        @language = args[:language]
        @script = args[:script]
        @locale = args[:locale]
      end
    end
  end
end
