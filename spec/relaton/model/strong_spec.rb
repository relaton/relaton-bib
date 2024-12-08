describe Relaton::Model::Strong do
  it "from XML" do
    xml = <<~XML
      <strong>
        Text
        <stem type="MathML"><any>Any</any>Stem</stem>
        <eref normative="true" citeas="REF" type="inline" alt="Alt" bibitem="ID">Eref</eref>
        <xref type="inline" bibitemid="ID" citeas="Citeas">Xref</xref>
        <link target="http://example.com" type="text/html" alt="Alt">Hyperlink<sup>1</sup></link>
        <index primary="true" type="inline">Index</index>
        <index-xref primary="true" type="inline" bibitemid="ID" citeas="Citeas">IndexXref</index-xref>
      </strong>
    XML
    strong = Relaton::Model::Strong.from_xml xml
    expect(strong.content).to be_instance_of Relaton::Model::Strong::Content
    expect(strong.to_xml).to be_equivalent_to xml
  end
end
