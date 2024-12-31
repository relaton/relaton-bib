describe "Relaton::Model::Keyword" do
  xit "parse & serialize" do
    xml = <<~XML
      <keyword>
        Text <em>Em</em>
        <index><primary>Index</primary></index>
        <index-xref><primary>Index Xref</primary></index-xref>
      </keyword>
    XML
    element = described_class.from_xml xml
    expect(element.to_xml).to be_equivalent_to xml
  end
end
