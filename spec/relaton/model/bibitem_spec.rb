describe Relaton::Model::Bibitem do
  it "parse XML" do
    xml = <<~XML
      <bibitem id="ID" type="standard" schema-version="1.2.3" fetched="2024-02-01">
        <formattedref><strong>Ref</strong>eren<em>ce</em></formattedref>
      </bibitem>
    XML
    doc = described_class.from_xml xml
    expect(doc.id).to eq "ID"
    expect(doc.type).to eq "standard"
    expect(doc.schema_version).to eq "1.2.3"
    expect(doc.formattedref).to be_instance_of Relaton::Bib::Formattedref
    expect(doc.fetched).to eq Date.new(2024, 2, 1)
  end

  it "to XML" do
    item = Relaton::Bib::Item.new
    item.id = "ID"
    item.type = "standard"
    item.schema_version = "1.2.3"
    item.fetched = Date.new 2024, 2, 1
    fref = Relaton::Bib::Formattedref.new
    fref.content = "Ref<em>eren</em>ce"
    item.formattedref = fref
    expect(described_class.to_xml(item)).to be_equivalent_to <<~XML
      <bibitem id="ID" type="standard" schema-version="1.2.3" fetched="2024-02-01"/>
    XML
  end
end
