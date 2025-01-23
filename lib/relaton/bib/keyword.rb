module Relaton
  module Bib
    class Keyword
      class Vocabid
        attr_accessor :type, :uri, :code, :term

        #
        # Vocabid initializer
        #
        # @param [String] type A label for the controlled vocabulary
        # @param [String, nil] uri A URI for the controlled vocabulary item
        # @param [String, nil] code The code or identifier for the controlled vocabulary item
        # @param [String, nil] term The term itself for the controlled vocabulary item
        #
        def initialize(**args)
          @type = args[:type]
          @uri  = args[:uri]
          @code = args[:code]
          @term = args[:term]
        end
      end

      attr_accessor :vocab, :taxon, :vocabid

      #
      # Keyword initializer
      #
      # @param [Relaton::Bib::LocalizedString, nil] vocab The keyword as a single, controlled or uncontrolled vocabulary item
      # @param [Array<Relation::Bib::LocalizedString>] taxon The keywords as a hierarchical taxonomy
      # @param [Array<Relaton::Bib::Keyword::Vocabid>] vocabid Identifiers for the keyword as a controlled vocabulary
      #
      def initialize(vocab: nil, taxon: [], vocabid: [])
        @vocab = vocab
        @taxon = taxon
        @vocabid = vocabid
      end
    end
  end
end
