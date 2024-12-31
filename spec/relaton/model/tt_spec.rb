describe "Relaton::Model::Tt" do
  xit "from XML" do
    xml = <<~XML
      <tt>
        <eref citeas="false" type="inline" bibitemid="ISO712">Text</eref>
        <xref target="ISO 712" type="inline">Text</xref>
        <link target="http://example.com" type="inline">Text</link>
        Text
        <index><primary>Primary</primary></index>
        <index-xref also="false"><primary>Primary</primary><target>Target</target></index-xref>
      </tt>
    XML
    tt = described_class.from_xml xml
    expect(tt.content).to be_instance_of Relaton::Model::Tt::Content
    expect(tt.to_xml).to be_equivalent_to xml
  end
end
