require_relative "doctype"
require_relative "editorial_group"
require_relative "ics"
require_relative "structured_identifier"

module Relaton
  module Bib
    class Ext
      attr_accessor :doctype, :subdoctype, :flavor, :editorialgroup, :ics

      attr_reader :structuredidentifier

      # @param doctype [Relaton::Bib::DocumentType]
      # @param subdoctype [String]
      # @param flavor [String]
      # @param editorialgroup [Relaton::Bib::EditorialGroup, nil]
      # @param ics [Array<Relaton::Bib::ICS>]
      # @param structuredidentifier [Relaton::Bib::StructuredIdentifierCollection]
      def initialize(**args)
        @doctype = args[:doctype]
        @subdoctype = args[:subdoctype]
        @flavor = args[:flavor]
        @editorialgroup = args[:editorialgroup]
        @ics = args[:ics] || []
        @structuredidentifier = args[:structuredidentifier] || StructuredIdentifierCollection.new
      end

      def structuredidentifier=(structuredidentifier)
        @structuredidentifier = case structuredidentifier
                                when StructuredIdentifierCollection
                                  structuredidentifier
                                else
                                  StructuredIdentifierCollection.new(structuredidentifier)
                                end
      end
    end
  end
end
