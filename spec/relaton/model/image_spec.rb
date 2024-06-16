describe Relaton::Model::Image do
  it "parse & serialize" do
    xml = <<~XML
      <image id="ID" src="SRC" mimetype="MIME" filename="FILENAME" width="WIDTH" height="HEIGHT" alt="ALT" title="TITLE" longdesc="LONGDESC"/>
    XML
    element = described_class.from_xml xml
    expect(element.id).to eq "ID"
    expect(element.src).to eq "SRC"
    expect(element.mimetype).to eq "MIME"
    expect(element.filename).to eq "FILENAME"
    expect(element.width).to eq "WIDTH"
    expect(element.height).to eq "HEIGHT"
    expect(element.alt).to eq "ALT"
    expect(element.title).to eq "TITLE"
    expect(element.longdesc).to eq "LONGDESC"
    expect(described_class.to_xml(element)).to be_equivalent_to xml
  end
end
