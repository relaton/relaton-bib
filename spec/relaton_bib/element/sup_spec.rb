describe RelatonBib::Element::Sup do
  subject { described_class.new([RelatonBib::Element::Text.new("sup")]) }

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <sup>sup</sup>
    XML
  end
end
