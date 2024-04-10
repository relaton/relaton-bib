describe RelatonBib::Element::Hr do
  it "creates hr" do
    item = RelatonBib::Element::Hr.new
    doc = Nokogiri::XML::Builder.new { |xml| item.to_xml xml }.doc.root
    expect(doc.to_xml).to be_equivalent_to "<hr/>"
  end
end
