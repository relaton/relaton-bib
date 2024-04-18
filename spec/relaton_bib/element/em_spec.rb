describe RelatonBib::Element::Em do
  subject { described_class.new content: [RelatonBib::Element::Text.new("Content")] }

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |xml| subject.to_xml xml }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <em>Content</em>
    XML
  end

  it "to_s" do
    expect(subject.to_s).to eq "<em>Content</em>"
  end
end
