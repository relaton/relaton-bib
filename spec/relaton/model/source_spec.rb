describe Relaton::Model::Source do
  it "parse XML" do
    xml = <<~XML
      <uri type="src" language="en" locale="EN-us" script="Latn">http://example.com</uri>
    XML
    doc = described_class.from_xml xml
    expect(doc.type).to eq "src"
    expect(doc.language).to eq "en"
    expect(doc.locale).to eq "EN-us"
    expect(doc.script).to eq "Latn"
    expect(doc.content).to be_instance_of Addressable::URI
    expect(doc.content.to_s).to eq "http://example.com"
  end

  it "to XML" do
    bsource = Relaton::Bib::Bsource.new
    bsource.type = "src"
    bsource.language = "en"
    bsource.locale = "EN-us"
    bsource.script = "Latn"
    bsource.content = "http://example.com"
    expect(Relaton::Model::Uri.to_xml(bsource)).to be_equivalent_to <<~XML
      <uri type="src" language="en" locale="EN-us" script="Latn">http://example.com</uri>
    XML
  end
end
