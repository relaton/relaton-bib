describe RelatonBib::Element::Pre do
  let(:text) { RelatonBib::Element::Text.new("Text") }

  subject do
    tname = RelatonBib::Element::Tname.new(content: [text])
    paragraph = RelatonBib::Element::Paragraph.new(content: [text], id: "id")
    note = RelatonBib::Element::Note.new(content: [paragraph], id: "id")
    described_class.new(id: "id", content: [text, note], alt: "alt", tname: tname)
  end

  it "initialize pre element" do
    expect(subject.content[0]).to be_instance_of RelatonBib::Element::Text
    expect(subject.content[1]).to be_instance_of RelatonBib::Element::Note
    expect(subject.id).to eq "id"
    expect(subject.alt).to eq "alt"
    expect(subject.tname).to be_instance_of RelatonBib::Element::Tname
  end

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <pre id="id" alt="alt">
        <name>Text</name>Text<note id="id"><p id="id">Text</p></note>
      </pre>
    XML
  end
end
