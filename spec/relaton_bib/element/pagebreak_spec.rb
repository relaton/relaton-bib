describe RelatonBib::Element::PageBreak do
  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <pagebreak/>
    XML
  end
end
