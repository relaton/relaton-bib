describe Relaton::Model::Strike do
  it "parse & serialize" do
    xml = <<~XML
      <strike>Text <em>Em</em></strike>
    XML
    element = Relaton::Model::Strike.from_xml xml
    expect(element.to_xml).to be_equivalent_to xml
  end
end
