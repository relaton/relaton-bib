describe RelatonBib::Element::Ol do
  let(:type) { "roman" }

  subject do
    li_content = RelatonBib::Element::ParagraphWithFootnote.new(content: [RelatonBib::Element::Text.new("content")])
    content = RelatonBib::Element::Li.new(content: [li_content])
    note_content = RelatonBib::Element::Paragraph.new(id: "pID", content: [RelatonBib::Element::Text.new("Note")])
    note = RelatonBib::Element::Note.new(id: "nID", content: [note_content])
    described_class.new(id: "ID", type: type, content: [content], note: [note], start: "1")
  end

  it "initialize ordered list element" do
    expect(subject.content[0]).to be_instance_of RelatonBib::Element::Li
    expect(subject.id).to eq "ID"
    expect(subject.type).to eq type
    expect(subject.note[0]).to be_instance_of RelatonBib::Element::Note
    expect(subject.start).to eq "1"
  end

  context "when type is invalid" do
    let(:type) { "invalid" }

    it "warn" do
      expect { subject }.to output(/invalid ordered list type: invalid/).to_stderr_from_any_process
    end
  end

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <ol start="1" id="ID" type="roman">
        <li><p>content</p></li>
        <note id="nID"><p id="pID">Note</p></note>
      </ol>
    XML
  end
end
