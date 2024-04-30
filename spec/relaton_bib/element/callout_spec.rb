describe RelatonBib::Element::Callout do
  subject do
    described_class.new target: "target", content: RelatonBib::Element::Text.new("content")
  end

  it "initialize" do
    expect(subject.content).to be_instance_of RelatonBib::Element::Text
    expect(subject.target).to eq "target"
  end

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <callout target="target">content</callout>
    XML
  end
end
