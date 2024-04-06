module RelatonBib
  module Parser
    module XML
      module Locality
        #
        # Parse locality
        #
        # @param rel [Nokogiri::XML::Element] relation element
        #
        # @return [Array<RelatonBib::Locality, RelatonBib::LocalityStack>] localities
        #
        def localities(rel)
          rel.xpath("./locality|./localityStack").map do |lc|
            if lc.name == "locality"
              locality lc
            else
              LocalityStack.new(lc.xpath("./locality").map { |l| locality l })
            end
          end
        end

        #
        # Create Locality object from Nokogiri::XML::Element
        #
        # @param loc [Nokogiri::XML::Element]
        # @param klass [RelatonBib::Locality, RelatonBib::LocalityStack]
        #
        # @return [RelatonBib::Locality]
        def locality(loc, klass = RelatonBib::Locality)
          klass.new(
            loc[:type],
            loc.at("./referenceFrom")&.text,
            loc.at("./referenceTo")&.text,
          )
        end

        # @param rel [Nokogiri::XML::Element]
        # @return [Array<RelatonBib::SourceLocality,
        #   RelatonBib::SourceLocalityStack>]
        def source_localities(rel)
          rel.xpath("./sourceLocality|./sourceLocalityStack").map do |lc|
            if lc[:type]
              SourceLocalityStack.new [locality(lc, SourceLocality)]
            else
              sls = lc.xpath("./sourceLocality").map do |l|
                locality l, SourceLocality
              end
              SourceLocalityStack.new sls
            end
          end
        end
      end
    end
  end
end
