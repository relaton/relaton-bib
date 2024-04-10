describe RelatonBib::Element::Em do
  subject { described_class.new [RelatonBib::Element::Text.new("content")] }

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |xml| subject.to_xml xml }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <em>content</em>
    XML
  end
end
