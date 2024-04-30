describe RelatonBib::Element::Quote do
  subject do
    source_content = RelatonBib::Element::Text.new "source"
    citation_type = RelatonBib::Element::CitationType.new "BibItemID"
    source = RelatonBib::Element::Quote::Source.new(
      content: [source_content], citeas: "citeas", type: "type", citation_type: citation_type
    )
    author = RelatonBib::Element::Quote::Author.new "author"
    content_text = RelatonBib::Element::Text.new "paragraph with footnote"
    content = RelatonBib::Element::ParagraphWithFootnote.new content: [content_text]
    note_content = RelatonBib::Element::Text.new "note"
    note_paragraph = RelatonBib::Element::Paragraph.new id: "pID", content: [note_content]
    note = RelatonBib::Element::Note.new id: "nID", content: [note_paragraph]
    described_class.new(
      id: "ID", alignment: "left", source: source, author: author, content: [content], note: [note]
    )
  end

  it "initialize" do
    expect(subject.id).to eq "ID"
    expect(subject.alignment).to eq "left"
    expect(subject.source).to be_instance_of RelatonBib::Element::Quote::Source
    expect(subject.author).to be_instance_of RelatonBib::Element::Quote::Author
    expect(subject.content[0]).to be_instance_of RelatonBib::Element::ParagraphWithFootnote
    expect(subject.note[0]).to be_instance_of RelatonBib::Element::Note
  end

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <quote id="ID" alignment="left">
        <p>paragraph with footnote</p>
        <source citeas="citeas" type="type" bibitemid="BibItemID">source</source>
        <author>author</author>
        <note id="nID"><p id="pID">note</p></note>
      </quote>
    XML
  end
end
