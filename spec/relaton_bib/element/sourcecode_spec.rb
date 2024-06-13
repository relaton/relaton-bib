describe RelatonBib::Element::Sourcecode do
  subject do
    content = RelatonBib::Element::Text.new("text")
    tname = RelatonBib::Element::Tname.new(content: [RelatonBib::Element::Text.new("tname")])
    paragraph = RelatonBib::Element::Paragraph.new(content: [RelatonBib::Element::Text.new("annotation")], id: "pID")
    annotation = RelatonBib::Element::Annotation.new(id: "aID", content: paragraph)
    note = RelatonBib::Element::Note.new(id: "nID", content: [RelatonBib::Element::Text.new("note")])
    described_class.new(
      id: "id", content: [content], annotation: [annotation], note: [note],
      unnumbered: true, subsequence: "SubSec", lang: "en", tname: tname
    )
  end

  it "initialize sourcecode" do
    expect(subject.content[0]).to be_instance_of RelatonBib::Element::Text
    expect(subject.id).to eq "id"
    expect(subject.annotation[0]).to be_instance_of RelatonBib::Element::Annotation
    expect(subject.note[0]).to be_instance_of RelatonBib::Element::Note
    expect(subject.unnumbered).to be true
    expect(subject.subsequence).to eq "SubSec"
    expect(subject.lang).to eq "en"
    expect(subject.tname).to be_instance_of RelatonBib::Element::Tname
  end

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <sourcecode id="id" unnumbered="true" subsequence="SubSec" lang="en">
        <name>tname</name>text<annotation id="aID"><p id="pID">annotation</p></annotation>
        <note id="nID">note</note>
      </sourcecode>
    XML
  end
end
