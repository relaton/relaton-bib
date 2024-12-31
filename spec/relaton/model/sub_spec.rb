describe "Relaton::Model::Sub" do
  xit "from XML" do
    xml = <<~XML
      <sub>
        Text
        <em>Em</em>
        <strong>Strong</strong>
      </sub>
    XML
    sub = Relaton::Model::Sub.from_xml xml
    expect(sub.content.size).to eq 3
    expect(sub.content[0]).to be_instance_of Relaton::Model::PureTextElement
    expect(sub.to_xml).to be_equivalent_to xml
  end
end
