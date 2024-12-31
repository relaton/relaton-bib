describe "Relaton::Model::Index" do
  xit "parse & serialize" do
    xml = <<~XML
      <index-xref also="false">
        <primary>Primary<em>Em</em></primary>
        <secondary>Secondary<strong>Strong</strong></secondary>
        <tertiary><sub>1</sub>Tertiary</tertiary>
        <target>Target<sup>2</sup></target>
      </index-xref>
    XML
    element = Relaton::Model::IndexXref.from_xml xml
    expect(element.primary).to be_instance_of Relaton::Model::Index::Content
    expect(element.to_xml).to be_equivalent_to xml
  end
end
