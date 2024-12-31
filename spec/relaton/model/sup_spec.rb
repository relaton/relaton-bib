describe "Relaton::Model::Sup" do
  xit "from XML" do
    xml = <<~XML
      <sup>
        Text
        <em>Em</em>
        <strong>Strong</strong>
      </sup>
    XML
    sup = Relaton::Model::Sup.from_xml xml
    expect(sup.content.size).to eq 3
    expect(sup.content[0]).to be_instance_of Relaton::Model::PureTextElement
    expect(sup.to_xml).to be_equivalent_to xml
  end
end
