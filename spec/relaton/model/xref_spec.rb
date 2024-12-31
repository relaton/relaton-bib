describe "Relaton::Model::Xref" do
  xit "parse & serialize" do
    xml = <<~XML
      <xref target="target" type="type" alt="alt">
        <strong>Strong</strong>
        Text
        <sub>Sub</sub>
      </xref>
    XML
    # element = Relaton::Model::Xref.from_xml xml
    expect(element.target).to eq "target"
    expect(element.type).to eq "type"
    expect(element.alt).to eq "alt"
    expect(element.to_xml).to be_equivalent_to xml
  end
end
