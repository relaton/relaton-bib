describe "Relaton::Model::Strike" do
  xit "parse & serialize" do
    xml = <<~XML
      <strike>
        Text <em>Em</em>
        <index><primary>Index</primary></index>
        <index-xref><primary>Index Xref</primary></index-xref>
      </strike>
    XML
    element = described_class.from_xml xml
    expect(element.to_xml).to be_equivalent_to xml
  end
end
