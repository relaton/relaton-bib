describe Relaton::Model::Title do
  context "parse & render" do
    it "with content" do
      xml = <<~XML
        <title type="main" language="en" script="Latn" locale="en-US"><em>Main</em> Title</title>
      XML
      title = described_class.from_xml xml
      expect(title.content).to be_instance_of Relaton::Model::LocalizedMarkedUpString::Content
      expect(title.type).to eq "main"
      expect(title.language).to eq "en"
      expect(title.script).to eq "Latn"
      expect(title.locale).to eq "en-US"
      expect(described_class.to_xml(title)).to be_equivalent_to xml
    end

    it "with variant" do
      xml = <<~XML
        <title type="main">
          <variant language="en" script="Latn" locale="en-US">
            <em>Main</em> Title
          </variant>
        </title>
      XML
      title = described_class.from_xml xml
      expect(title.content).to be_instance_of Relaton::Model::LocalizedMarkedUpString::Variants
      expect(described_class.to_xml(title)).to be_equivalent_to xml
    end
  end
end
