describe Relaton::Model::Person do
  it "parse XML" do
    xml = <<~XML
      <person>
        <name><completename>John Doe</completename></name>
        <credential>PhD</credential>
        <affiliation>
          <organization><name>ISO</name></organization>
        </affiliation>
        <identifier type="uri">https://example.com</identifier>
        <contact>
          <phone type="mobile">123456789</phone>
        </contact>
      </person>
    XML
    person = described_class.from_xml xml
    expect(person.name.completename.content).to eq "John Doe"
  end
end
