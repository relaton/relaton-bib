describe RelatonBib::Element::Hyperlink do
  let(:content) { RelatonBib::Element::Text.new("text") }
  subject { described_class.new([content], "http://example.com", "external", "alt") }
  it "initialize hyperlink" do
    expect(subject.content).to eq [content]
    expect(subject.link).to eq "http://example.com"
    expect(subject.type).to eq "external"
    expect(subject.alt).to eq "alt"
  end

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <hyperlink link="http://example.com" type="external" alt="alt">text</hyperlink>
    XML
  end
end
