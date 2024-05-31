describe Relaton::Model::Em do
  it "from XML" do
    xml = <<~XML
      <em>text</em>
    XML
    em = described_class.from_xml xml
    expect(em.content).to eq "text"
  end
end
