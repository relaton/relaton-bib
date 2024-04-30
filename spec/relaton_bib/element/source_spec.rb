describe RelatonBib::Element::Source do
  subject do
    described_class.new(
      content: "http://example.com", type: "src", language: "en", script: "Latn", locale: "US"
    )
  end

  it "initialize" do
    expect(subject.content).to be_instance_of Addressable::URI
    expect(subject.type).to eq "src"
    expect(subject.language).to eq "en"
    expect(subject.script).to eq "Latn"
    expect(subject.locale).to eq "US"
  end

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <source type="src" language="en" script="Latn" locale="US">http://example.com</source>
    XML
  end
end
