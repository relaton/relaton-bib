describe RelatonBib::Element::ParagraphWithFootnote do
  let(:content) { RelatonBib::Element::Text.new("text") }
  let(:note) do
    c = RelatonBib::Element::Text.new("Note")
    p = RelatonBib::Element::Paragraph.new([c], "id-2")
    RelatonBib::Element::Note.new([p], "id-3")
  end

  subject do
    described_class.new([content], "id-1", align: "left", note: [note])
  end

  it "initialize paragraph with footnote" do
    expect(subject.content).to eq [content]
    expect(subject.id).to eq "id-1"
    expect(subject.align).to eq "left"
    expect(subject.note).to eq [note]
  end

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <p id="id-1" align="left">
        text
        <note id="id-3">
          <p id="id-2">Note</p>
        </note>
      </p>
    XML
  end

  it "to_s" do
    expect(subject.to_s).to eq(
      "<p id=\"id-1\" align=\"left\">text<note id=\"id-3\"><p id=\"id-2\">Note</p></note></p>"
    )
  end
end
