describe Relaton::Model::Em do
  let(:xml) do
    <<~XML
      <em>
        Text
        <stem type="MathML">Stem</stem>
      </em>
    XML
  end

  it "from XML" do
    em = described_class.from_xml xml
    expect(em.content).to be_instance_of Relaton::Model::Em::Content
    expect(em.to_xml).to be_equivalent_to xml
  end

  it "to XML" do
    stem = Relaton::Model::Stem.new
    stem.type = "MathML"
    stem.content = Relaton::Model::AnyElement.new "text", "Stem"

    em = described_class.new
    em.content = described_class::Content.new ["Text", stem]

    expect(described_class.to_xml(em)).to be_equivalent_to <<~XML
      <em>
        Text
        <stem type="MathML">Stem</stem>
      </em>
    XML
  end
end
