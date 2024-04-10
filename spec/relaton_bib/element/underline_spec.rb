describe RelatonBib::Element::Underline do
  let(:content) { RelatonBib::Element::Text.new "content" }
  subject { RelatonBib::Element::Underline.new [content], "style" }

  it "returns content" do
    expect(subject.content).to eq [content]
    expect(subject.style).to eq "style"
  end

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <underline style="style">content</underline>
    XML
  end
end
