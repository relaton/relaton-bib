describe RelatonBib::Element::Ul do
  subject do
    item = RelatonBib::Element::Li.new content: [RelatonBib::Element::Text.new("item")]
    note_content = RelatonBib::Element::Text.new "note"
    paragraph = RelatonBib::Element::Paragraph.new id: "pID", content: [note_content]
    note = RelatonBib::Element::Note.new id: "nID", content: [paragraph]
    described_class.new id: "ID", content: [item], note: [note]
  end

  it "initialize ul element" do
    expect(subject.content[0]).to be_instance_of RelatonBib::Element::Li
  end

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <ul id="ID"><li>item</li><note id="nID"><p id="pID">note</p></note></ul>
    XML
  end
end
