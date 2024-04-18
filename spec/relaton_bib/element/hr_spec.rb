describe RelatonBib::Element::Hr do
  subject { described_class.new }

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |xml| subject.to_xml xml }.doc.root
    expect(doc.to_xml).to be_equivalent_to "<hr/>"
  end

  it "to_s" do
    expect(subject.to_s).to eq "<hr/>"
  end
end
