describe RelatonBib::Element::Tt do
  subject { described_class.new([RelatonBib::Element::Text.new("tt")]) }

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <tt>tt</tt>
    XML
  end
end
