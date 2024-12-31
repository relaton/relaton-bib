describe Relaton::Model::Em do
  let(:xml) do
    <<~XML
      <em>
        Text
        <stem type="MathML">Stem</stem>
        <eref citeas="ISO 712" type="inline" bibitemid="ISO712">Text</eref>
        <xref target="ISO 712" type="inline">Text</xref>
        <link target="ISO 712" type="inline">Text</link>
        <index><primary>Primary</primary></index>
        <index-xref also="false"><primary>Primary</primary><target>Target</target></index-xref>
      </em>
    XML
  end

  it "from XML" do
    em = described_class.from_xml xml
    expect(em.content).to include "Text\n  <stem type=\"MathML\">Stem</stem>\n"
    expect(em.to_xml).to be_equivalent_to xml
  end

  xit "to XML" do
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
