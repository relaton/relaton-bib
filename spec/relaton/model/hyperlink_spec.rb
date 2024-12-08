describe Relaton::Model::Hyperlink do
  it "parse & serialize" do
    xml = <<~XML
      <link target="http://example.com" type="text/html" alt="Alt">
        Hyperlink<sup>1</sup>
      </link>
    XML
    element = described_class.from_xml xml
    expect(element.to_xml).to be_equivalent_to xml
  end
end
