describe Relaton::Model::Tt do
  it "from XML" do
    xml = <<~XML
      <tt>
        Text
        <em>Em</em>
        <eref type="inline" bibitemid="ISO712">
          <locality type="section"><referenceFrom>1</referenceFrom></locality>
        </eref>
      </tt>
    XML
    tt = Relaton::Model::Tt.from_xml xml
    expect(tt.content).to be_instance_of Relaton::Model::Tt::Content
    expect(tt.to_xml).to be_equivalent_to xml
  end
end
