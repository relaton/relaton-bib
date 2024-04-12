module RelatonBib
  module Element
    #
    # Module for converting element to string.
    #
    module ToString
      def to_string
        Nokogiri::XML::Builder.new do |b|
          to_xml b
        end.to_xml(save_with: Nokogiri::XML::Node::SaveOptions::NO_DECLARATION).chomp
      end
    end
  end
end
