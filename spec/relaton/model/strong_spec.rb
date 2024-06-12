describe Relaton::Model::Strong do
  it "from XML" do
    xml = <<~XML
      <strong>
        <text>Text</text>
        <stem>Stem</stem>
      </strong>
    XML
    strong = Relaton::Model::Strong.from_xml xml
    expect(strong.content).to be_instance_of Relaton::Model::Strong::Content
    expect(strong.to_xml).to be_equivalent_to xml
  end
end
