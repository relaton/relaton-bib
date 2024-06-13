describe RelatonBib::Element::Table do
  subject do
    tname = RelatonBib::Element::Tname.new(content: [RelatonBib::Element::Text.new("Tname")])
    td = RelatonBib::Element::Td.new(content: [RelatonBib::Element::Text.new("Td")])
    tr = RelatonBib::Element::Tr.new(content: [td])
    thead = RelatonBib::Element::Thead.new(tr)
    tbody = RelatonBib::Element::Tbody.new(content: [tr])
    tfoot = RelatonBib::Element::Tfoot.new(tr)
    paragraph = RelatonBib::Element::Paragraph.new(id: "pID", content: [RelatonBib::Element::Text.new("Note")])
    note = RelatonBib::Element::Table::Note.new(paragraph)
    dt = RelatonBib::Element::Dt.new(content: [RelatonBib::Element::Text.new("Dt")])
    dl = RelatonBib::Element::Dl.new(id: "dlID", content: [dt])
    described_class.new(
      id: "id", unnumbered: false, subsequence: "Sub sec", alt: "alt", summary: "Sum", uri: "uri",
      tname: tname, thead: thead, tbody: tbody, tfoot: tfoot, note: [note], dl: dl
    )
  end

  it "initialize table" do
    expect(subject.id).to eq "id"
    expect(subject.unnumbered).to be false
    expect(subject.subsequence).to eq "Sub sec"
    expect(subject.alt).to eq "alt"
    expect(subject.summary).to eq "Sum"
    expect(subject.uri).to eq "uri"
    expect(subject.tname).to be_instance_of RelatonBib::Element::Tname
    expect(subject.thead).to be_instance_of RelatonBib::Element::Thead
    expect(subject.tbody).to be_instance_of RelatonBib::Element::Tbody
    expect(subject.tfoot).to be_instance_of RelatonBib::Element::Tfoot
    expect(subject.note[0]).to be_instance_of RelatonBib::Element::Table::Note
    expect(subject.dl).to be_instance_of RelatonBib::Element::Dl
  end

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <table id="id" unnumbered="false" subsequence="Sub sec" alt="alt" summary="Sum" uri="uri">
        <name>Tname</name>
        <thead>
          <tr>
            <td>Td</td>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>Td</td>
          </tr>
        </tbody>
        <tfoot>
          <tr>
            <td>Td</td>
          </tr>
        </tfoot>
        <note>
          <p id="pID">Note</p>
        </note>
        <dl id="dlID">
          <dt>Dt</dt>
        </dl>
      </table>
    XML
  end
end
