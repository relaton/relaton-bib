describe RelatonBib::Element::Stem do
  let(:content) { RelatonBib::Element::Text.new "content" }
  subject { RelatonBib::Element::Stem.new content: [content], type: "MathML" }

  it "returns content" do
    expect(subject.content).to eq [content]
    expect(subject.type).to eq "MathML"
  end

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to "<stem type=\"MathML\">content</stem>"
  end

  it "to_s" do
    expect(subject.to_s).to eq "<stem type=\"MathML\">content</stem>"
  end
end
