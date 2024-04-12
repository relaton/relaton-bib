describe RelatonBib::Element::Strong do
  subject { described_class.new([RelatonBib::Element::Text.new("strong")]) }

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <strong>strong</strong>
    XML
  end
end
