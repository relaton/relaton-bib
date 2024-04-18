describe RelatonBib::Element::Hyperlink do
  let(:content) { RelatonBib::Element::Text.new("text") }
  subject { described_class.new([content], "http://example.com", "external", "alt") }
  it "initialize hyperlink" do
    expect(subject.content).to eq [content]
    expect(subject.target).to eq "http://example.com"
    expect(subject.type).to eq "external"
    expect(subject.alt).to eq "alt"
  end

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <link target="http://example.com" type="external" alt="alt">text</link>
    XML
  end

  it "to_s" do
    expect(subject.to_s).to eq "<link target=\"http://example.com\" type=\"external\" alt=\"alt\">text</link>"
  end
end
