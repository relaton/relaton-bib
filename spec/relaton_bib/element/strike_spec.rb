describe RelatonBib::Element::Strike do
  subject { described_class.new(content: [RelatonBib::Element::Text.new("strike")]) }

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to "<strike>strike</strike>"
  end

  it "to_s" do
    expect(subject.to_s).to eq "<strike>strike</strike>"
  end
end
