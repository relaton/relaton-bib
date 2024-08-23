describe Relaton::Model::LocalizedMarkedUpString do
  let(:fake_class) do
    Class.new(Lutaml::Model::Serializable) do
      include Relaton::Model::LocalizedMarkedUpString

      mappings[:xml].instance_eval do
        root "item"
      end
    end
  end

  context "XML mapping" do
    it "with TextElement" do
      xml = <<~XML
        <item language="en" script="Latn" locale="US"><strong>Strong</strong>Text</item>
      XML
      item = fake_class.from_xml xml
      expect(item.content).to be_instance_of Relaton::Model::LocalizedMarkedUpString::Content
      expect(item.language).to eq "en"
      expect(item.script).to eq "Latn"
      expect(item.locale).to eq "US"
      expect(item.to_xml).to be_equivalent_to xml
    end

    it "with Variant" do
      xml = <<~XML
        <item>
          <variant language="en" script="Latn" locale="US">
            <strong>Strong</strong>Text
          </variant>
        </item>
      XML
      item = fake_class.from_xml xml
      expect(item.content).to be_instance_of Relaton::Model::LocalizedMarkedUpString::Variants
      expect(item.to_xml).to be_equivalent_to xml
    end
  end
end
