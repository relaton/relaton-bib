describe RelatonBib::Element::Stem do
  let(:content) { RelatonBib::Element::Text.new "content" }
  subject { RelatonBib::Element::Stem.new [content], "MathML" }

  it "returns content" do
    expect(subject.content).to eq [content]
    expect(subject.type).to eq "MathML"
  end

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <stem type="MathML">content</stem>
    XML
  end
end
