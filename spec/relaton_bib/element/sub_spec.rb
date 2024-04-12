describe RelatonBib::Element::Sub do
  subject { described_class.new([RelatonBib::Element::Text.new("sub")]) }

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <sub>sub</sub>
    XML
  end
end
