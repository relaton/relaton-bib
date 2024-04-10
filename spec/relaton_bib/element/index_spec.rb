describe RelatonBib::Element::Index do
  let(:primary) { RelatonBib::Element::Text.new "Primary" }
  let(:secondary) { RelatonBib::Element::Text.new "Secondary" }
  let(:tertiary) { RelatonBib::Element::Text.new "Tertiary" }

  subject do
    described_class.new([primary], secondary: [secondary], tertiary: [tertiary], to: "To")
  end

  it "initialize index element" do
    expect(subject.primary).to eq([primary])
    expect(subject.secondary).to eq([secondary])
    expect(subject.tertiary).to eq([tertiary])
    expect(subject.to).to eq "To"
  end

  it "to_xml" do
    xml = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(xml.to_xml).to be_equivalent_to <<~XML
      <index to="To">
        <primary>Primary</primary>
        <secondary>Secondary</secondary>
        <tertiary>Tertiary</tertiary>
      </index>
    XML
  end
end

describe RelatonBib::Element::IndexXref do
  let(:primary) { RelatonBib::Element::Text.new "Primary" }
  let(:secondary) { RelatonBib::Element::Text.new "Secondary" }
  let(:tertiary) { RelatonBib::Element::Text.new "Tertiary" }
  let(:target) { RelatonBib::Element::Text.new "Target" }

  subject do
    described_class.new([primary], secondary: [secondary], tertiary: [tertiary], target: [target], also: true)
  end

  it "initialize index xref element" do
    expect(subject.primary).to eq([primary])
    expect(subject.secondary).to eq([secondary])
    expect(subject.tertiary).to eq([tertiary])
    expect(subject.target).to eq([target])
    expect(subject.also).to be true
  end

  it "to_xml" do
    xml = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(xml.to_xml).to be_equivalent_to <<~XML
      <index-xref also="true">
        <primary>Primary</primary>
        <secondary>Secondary</secondary>
        <tertiary>Tertiary</tertiary>
        <target>Target</target>
      </index-xref>
    XML
  end
end
