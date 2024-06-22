describe Relaton::Model::Index do
  it "parse & serialize" do
    xml = <<~XML
      <index to="to">
        <primary>Primary<em>Em</em></primary>
        <secondary>Secondary<strong>Strong</strong></secondary>
        <tertiary>Tertiary</tertiary>
      </index>
    XML
    element = Relaton::Model::Index.from_xml xml
    expect(element.primary).to be_instance_of Relaton::Model::Index::Content
    expect(element.to_xml).to be_equivalent_to xml
  end
end
