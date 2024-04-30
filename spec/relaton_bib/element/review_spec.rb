describe RelatonBib::Element::Review do
  subject do
    text = RelatonBib::Element::Text.new("text")
    paragraph = RelatonBib::Element::Paragraph.new(id: "pID", content: [text])
    described_class.new(id: "id", reviewer: "reviewer", content: [paragraph],
                        type: "Type", date: "11-11-1999", from: "from", to: "to")
  end

  it "initialize review" do
    expect(subject.id).to eq "id"
    expect(subject.reviewer).to eq "reviewer"
    expect(subject.content[0]).to be_instance_of RelatonBib::Element::Paragraph
    expect(subject.type).to eq "Type"
    expect(subject.date).to eq "11-11-1999"
    expect(subject.from).to eq "from"
    expect(subject.to).to eq "to"
  end

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <review id="id" reviewer="reviewer" type="Type" date="11-11-1999" from="from" to="to">
        <p id="pID">text</p>
      </review>
    XML
  end
end
