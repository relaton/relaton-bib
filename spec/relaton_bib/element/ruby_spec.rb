describe RelatonBib::Element::Ruby do
  let(:content) { RelatonBib::Element::Text.new "content" }
  let(:annotation) do
    RelatonBib::Element::Annotation.new "annotation", script: "Latn", lang: "en"
  end
  subject { described_class.new content, annotation }

  it "initialize ruby" do
    expect(subject.content).to eq content
    expect(subject.annotation).to eq annotation
  end

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <ruby><annotation value="annotation" script="Latn" lang="en"/>content</ruby>
    XML
  end

  it "to_s" do
    expect(subject.to_s).to eq(
      "<ruby><annotation value=\"annotation\" script=\"Latn\" lang=\"en\"/>content</ruby>"
    )
  end
end

describe RelatonBib::Element::Annotation do
  subject { described_class.new "value", script: "Latn", lang: "en" }

  it "initialize annotation" do
    expect(subject.value).to eq "value"
    expect(subject.script).to eq "Latn"
    expect(subject.lang).to eq "en"
  end

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <annotation value="value" script="Latn" lang="en"/>
    XML
  end

  it "to_s" do
    expect(subject.to_s).to eq "<annotation value=\"value\" script=\"Latn\" lang=\"en\"/>"
  end
end

describe RelatonBib::Element::Pronunciation do
  subject { described_class.new "value", script: "Latn", lang: "en" }

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <pronunciation value="value" script="Latn" lang="en"/>
    XML
  end

  it "to_s" do
    expect(subject.to_s).to eq "<pronunciation value=\"value\" script=\"Latn\" lang=\"en\"/>"
  end
end
