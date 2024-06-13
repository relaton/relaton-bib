describe RelatonBib::Element::Sup do
  subject { described_class.new(content: [RelatonBib::Element::Text.new("sup")]) }

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to "<sup>sup</sup>"
  end

  it "to_s" do
    expect(subject.to_s).to eq "<sup>sup</sup>"
  end
end
