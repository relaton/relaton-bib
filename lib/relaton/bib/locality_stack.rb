module Relaton
  module Bib
    class LocalityStack
      # include Relaton

      # @return [String]
      attr_accessor :connective

      # @return [Array<Relaton::Bib::Locality>]
      attr_accessor :locality

      # @param locality [Array<Relaton::Bib::Locality>]
      def initialize(locality = [])
        @locality = locality
      end

      # @return [String]
      def to_xml
        Model::LocalityStack.to_xml self
      end

      # @returnt [Hash]
      # def to_hash
      #   { "locality_stack" => single_element_array(locality) }
      # end

      #
      # Render locality stack as AsciiBib.
      #
      # @param [String] prefix <description>
      # @param [Integer] size size of locality stack
      #
      # @return [String] AsciiBib.
      #
      def to_asciibib(prefix = "", size = 1)
        pref = prefix.empty? ? "locality_stack" : "#{prefix}.locality_stack"
        out = ""
        out << "#{pref}::\n" if size > 1
        out << locality.map { |l| l.to_asciibib(pref, locality.size) }.join
      end

      #
      # Render locality stack as BibTeX.
      #
      # @param [BibTeX::Entry] item BibTeX entry.
      #
      def to_bibtex(item)
        locality.each { |l| l.to_bibtex(item) }
      end
    end

    class SourceLocalityStack
      attr_accessor :connective, :source_locality

      # @param connective [String, nil]
      # @param source_locality [Array<Relaton::Bib::SourceLocality>]
      def initialize(connective: nil, source_locality: [])
        @connective = connective
        @source_locality = source_locality
      end

      # @param builder [Nokogiri::XML::Builder]
      # def to_xml(builder)
      #   builder.sourceLocalityStack do |b|
      #     locality.each { |l| l.to_xml(b) }
      #   end
      # end

      # @returnt [Hash]
      # def to_hash
      #   { "source_locality_stack" => single_element_array(locality) }
      # end
    end
  end
end
