module RelatonBib
  module Element
    #
    # Module for converting element to string.
    #
    module ToString
      def to_s
        node = Nokogiri::XML::Builder.new { |b| to_xml b }.doc.root
        node.to_xml(save_with: Nokogiri::XML::Node::SaveOptions::NO_DECLARATION).chomp
      end
    end
  end
end
