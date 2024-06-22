describe Relaton::Model::Formattedref do
  let(:xml) do
    "<formattedref><strong>Strong</strong>content<em>Em</em></formattedref>"
  end

  it "parse XML" do
    formattedref = described_class.from_xml xml
    expect(formattedref).to be_instance_of Relaton::Bib::Formattedref
    expect(formattedref.content).to be_instance_of Array
    expect(formattedref.content.size).to eq 3
    expect(formattedref.content[0]).to be_instance_of Relaton::Model::TextElement
    expect(formattedref.content[1]).to be_instance_of Relaton::Model::TextElement
    expect(formattedref.content[2]).to be_instance_of Relaton::Model::TextElement
    expect(described_class.to_xml(formattedref)).to be_equivalent_to xml
  end

  it "parse XML" do
    formattedref = Relaton::Bib::Formattedref.new
    formattedref.content = "<strong>Strong</strong>content<em>Em</em>"
    expect(formattedref.content).to be_instance_of Array
    expect(formattedref.content.size).to eq 3
    expect(described_class.to_xml(formattedref)).to be_equivalent_to xml
  end
end
