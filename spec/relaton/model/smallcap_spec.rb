describe "Relaton::Model::Smallcap" do
  xit "parse & serialize" do
    xml = <<~XML
      <smallcap>Text<em>Em</em></smallcap>
    XML
    element = described_class.from_xml xml
    expect(element.to_xml).to be_equivalent_to xml
  end
end
