describe RelatonBib::Element::PageBreak do
  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to "<pagebreak/>"
  end

  it "to_s" do
    expect(subject.to_s).to eq "<pagebreak/>"
  end
end
