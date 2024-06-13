describe Relaton::Model::Underline do
  it "parse & serialize" do
    xml = <<~XML
      <underline style="dotted">Text<em>Em</em></underline>
    XML
    element = described_class.from_xml xml
    expect(element.style).to eq "dotted"
    expect(element.to_xml.to_s).to be_equivalent_to xml
  end
end
