describe Relaton::Model::Formattedref do
  let(:xml) do
    "<formattedref><strong>Strong</strong>Content<em>Em</em></formattedref>"
  end

  it "parse XML" do
    formattedref = described_class.from_xml xml
    expect(formattedref).to be_instance_of Relaton::Bib::Formattedref
    expect(formattedref.content).to eq "<strong>Strong</strong>Content<em>Em</em>"
    expect(described_class.to_xml(formattedref)).to be_equivalent_to xml
  end
end
