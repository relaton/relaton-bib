describe RelatonBib::Element::Formula do
  subject do
    stem = RelatonBib::Element::Stem.new(type: "MathML", content: [RelatonBib::Element::Text.new("stem")])
    paragraphfn = RelatonBib::Element::ParagraphWithFootnote.new(content: [RelatonBib::Element::Text.new("paragraph")])
    dd = RelatonBib::Element::Dd.new(content: [paragraphfn])
    dl = RelatonBib::Element::Dl.new(id: "dlID", content: [dd])
    paragraph = RelatonBib::Element::Paragraph.new(id: "pID", content: [RelatonBib::Element::Text.new("note")])
    note = RelatonBib::Element::Note.new(content: [paragraph], id: "noteID")
    described_class.new(
      id: "id", unnumbered: true, subsequence: "SubSec", inequality: false, stem: stem, dl: dl, note: [note]
    )
  end

  it "initialize formula element" do
    expect(subject.id).to eq "id"
    expect(subject.unnumbered).to be true
    expect(subject.subsequence).to eq "SubSec"
    expect(subject.inequality).to be false
    expect(subject.stem).to be_instance_of RelatonBib::Element::Stem
    expect(subject.dl).to be_instance_of RelatonBib::Element::Dl
    expect(subject.note[0]).to be_instance_of RelatonBib::Element::Note
  end

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <formula id="id" unnumbered="true" subsequence="SubSec" inequality="false">
        <stem type="MathML">stem</stem>
        <dl id="dlID"><dd><p>paragraph</p></dd></dl>
        <note id="noteID"><p id="pID">note</p></note>
      </formula>
    XML
  end
end
