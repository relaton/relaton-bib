describe Relaton::Model::Biblionote do
  let(:xml) do
     <<~XML
      <note type="note" language="en" script="Latn" locale="US">Note</note>
    XML
  end

  it "from XML" do
    note = described_class.from_xml xml
    expect(note.type).to eq "note"
    expect(note.content).to be_instance_of Relaton::Model::LocalizedMarkedUpString::Content
    expect(described_class.to_xml(note)).to be_equivalent_to xml
  end

  it "to XML" do
    note = Relaton::Bib::BiblioNote.new type: "note", content: "Note", language: "en", script: "Latn", locale: "US"
    expect(described_class.to_xml(note)).to be_equivalent_to xml
  end
end
