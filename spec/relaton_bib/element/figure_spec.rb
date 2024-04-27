describe RelatonBib::Element::Figure do
  subject do
    content = RelatonBib::Element::Text.new("text")
    pfn = RelatonBib::Element::Paragraph.new(id: "ID", content: [RelatonBib::Element::Text.new("paragraph")])
    fn = RelatonBib::Element::Fn.new(reference: "REF", content: [pfn])
    pnote = RelatonBib::Element::Paragraph.new(id: "ID", content: [RelatonBib::Element::Text.new("paragraph")])
    note = RelatonBib::Element::Note.new(id: "ID", content: [pnote])
    source = RelatonBib::Element::Source.new content: "domain.org"
    tname = RelatonBib::Element::Tname.new content: [RelatonBib::Element::Text.new("TName")]
    dt = RelatonBib::Element::Dt.new content: [RelatonBib::Element::Text.new("DT")]
    dl = RelatonBib::Element::Dl.new id: "dlID", content: [dt]
    described_class.new(
      id: "id-1", content: [content], fn: [fn], note: [note], unnumbered: false, subsequence: "Sub sec",
      class: "Class", source: source, tname: tname, dl: dl
    )
  end

  it "initialize figure" do
    expect(subject.id).to eq "id-1"
    expect(subject.content[0]).to be_instance_of RelatonBib::Element::Text
    expect(subject.fn[0]).to be_instance_of RelatonBib::Element::Fn
    expect(subject.note[0]).to be_instance_of RelatonBib::Element::Note
    expect(subject.unnumbered).to be false
    expect(subject.subsequence).to eq "Sub sec"
    expect(subject.klass).to eq "Class"
    expect(subject.source).to be_instance_of RelatonBib::Element::Source
    expect(subject.tname).to be_instance_of RelatonBib::Element::Tname
    expect(subject.dl).to be_instance_of RelatonBib::Element::Dl
  end

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <figure id="id-1" unnumbered="false" subsequence="Sub sec" class="Class">
        <source>domain.org</source>
        <name>TName</name>text<fn reference="REF"><p id="ID">paragraph</p></fn>
        <dl id="dlID"><dt>DT</dt></dl>
        <note id="ID"><p id="ID">paragraph</p></note>
      </figure>
    XML
  end
end
