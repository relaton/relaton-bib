describe RelatonBib::Element::Tt do
  subject { described_class.new(content: [RelatonBib::Element::Text.new("tt")]) }

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to "<tt>tt</tt>"
  end

  it "to_s" do
    expect(subject.to_s).to eq "<tt>tt</tt>"
  end
end
