describe RelatonBib::Element::Smallcap do
  subject do
    described_class.new content: [RelatonBib::Element::Text.new("keyword")]
  end

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to "<smallcap>keyword</smallcap>"
  end

  it "to_s" do
    expect(subject.to_s).to eq "<smallcap>keyword</smallcap>"
  end
end
