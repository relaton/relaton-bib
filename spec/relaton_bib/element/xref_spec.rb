describe RelatonBib::Element::Xref do
  let(:content) { RelatonBib::Element::Text.new("text") }
  subject { described_class.new([content], "id-1", "anchor", "id-2") }

  it "initialize xref" do
    expect(subject.content).to eq [content]
    expect(subject.target).to eq "id-1"
    expect(subject.type).to eq "anchor"
    expect(subject.alt).to eq "id-2"
  end

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <xref target="id-1" type="anchor" alt="id-2">text</xref>
    XML
  end

  it "to_s" do
    expect(subject.to_s).to eq "<xref target=\"id-1\" type=\"anchor\" alt=\"id-2\">text</xref>"
  end
end
