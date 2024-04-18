describe RelatonBib::Element::Keyword do
  subject do
    described_class.new(content: [RelatonBib::Element::Text.new("keyword")])
  end
  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to "<keyword>keyword</keyword>"
  end

  it "to_s" do
    expect(subject.to_s).to eq "<keyword>keyword</keyword>"
  end
end
