describe RelatonBib::Element::Admonition do
  let (:type) { "tip" }

  subject do
    content = RelatonBib::Element::ParagraphWithFootnote.new(content: [RelatonBib::Element::Text.new("content")])
    note_content = RelatonBib::Element::Paragraph.new(id: "pID", content: [RelatonBib::Element::Text.new("Note")])
    note = RelatonBib::Element::Note.new(content: [note_content], id: "ID")
    tname = RelatonBib::Element::Tname.new(content: [RelatonBib::Element::Text.new("tname")])
    described_class.new(
      id: "ID", type: type, content: [content], note: [note], class: "class", url: "url", tname: tname
    )
  end

  it "initialize admonition" do
    expect(subject.content[0]).to be_instance_of RelatonBib::Element::ParagraphWithFootnote
    expect(subject.id).to eq "ID"
    expect(subject.type).to eq "tip"
    expect(subject.note[0]).to be_instance_of RelatonBib::Element::Note
    expect(subject.klass).to eq "class"
    expect(subject.url).to eq "url"
    expect(subject.tname).to be_instance_of RelatonBib::Element::Tname
  end

  context "warn when type is not valid" do
    let(:type) { "invalid" }

    it do
      expect { subject }.to output(
        /admonition type should be one of: warning, note, tip, important, caution/
      ).to_stderr_from_any_process
    end
  end

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <p id="ID" type="tip" class="class" url="url">
        <name>tname</name><p>content</p>
        <note id="ID"><p id="pID">Note</p></note>
      </p>
    XML
  end
end
