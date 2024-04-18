describe RelatonBib::Element::Sub do
  subject { described_class.new(content: [RelatonBib::Element::Text.new("sub")]) }

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to "<sub>sub</sub>"
  end

  it "to_s" do
    expect(subject.to_s).to eq "<sub>sub</sub>"
  end
end
