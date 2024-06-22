describe Relaton::Model::Stem do
  let(:xml) { '<stem type="MathML">Text<div><h1>Title</h1>Block</div></stem>' }

  it "from XML" do
    stem = described_class.from_xml xml
    expect(stem.type).to eq "MathML"
    expect(stem.content).to be_instance_of Relaton::Model::Collection
    expect(stem.to_xml).to eq xml
  end

  it "to XML" do
    stem = described_class.new
    stem.type = "MathML"
    stem.content = Relaton::Model::Collection.new [Relaton::Model::AnyElement.new("text", "Text")]
    h1_cont = Relaton::Model::AnyElement.new("text", "Title")
    div_cont = Relaton::Model::Collection.new [Relaton::Model::AnyElement.new("h1", h1_cont)]
    div_cont << Relaton::Model::AnyElement.new("text", "Block")
    stem.content << Relaton::Model::AnyElement.new("div", div_cont)
    expect(stem.to_xml).to be_equivalent_to xml
  end
end
