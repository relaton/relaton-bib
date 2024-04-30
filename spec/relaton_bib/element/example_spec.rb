describe RelatonBib::Element::Example do
  subject do
    content = RelatonBib::Element::ParagraphWithFootnote.new(content: [RelatonBib::Element::Text.new("content")])
    note_content = RelatonBib::Element::Paragraph.new(id: "pID", content: [RelatonBib::Element::Text.new("Note")])
    note = RelatonBib::Element::Note.new(content: [note_content], id: "nID")
    tname = RelatonBib::Element::Tname.new(content: [RelatonBib::Element::Text.new("tname")])
    described_class.new(
      id: "ID", content: [content], note: [note], unnumbered: false, subsequence: "SubSec", tname: tname
    )
  end

  it "initialize example" do
    expect(subject.id).to eq "ID"
    expect(subject.content[0]).to be_instance_of RelatonBib::Element::ParagraphWithFootnote
    expect(subject.note[0]).to be_instance_of RelatonBib::Element::Note
    expect(subject.unnumbered).to be false
    expect(subject.subsequence).to eq "SubSec"
    expect(subject.tname).to be_instance_of RelatonBib::Element::Tname
  end

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <example id="ID" subsequence="true">
        <name>tname</name><p>content</p>
        <note id="nID"><p id="pID">Note</p></note>
      </example>
    XML
  end
end
