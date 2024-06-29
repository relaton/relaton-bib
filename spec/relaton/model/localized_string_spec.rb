describe Relaton::Model::LocalizedString do
  let(:fake_class) do
    Class.new(Shale::Mapper) do
      include Relaton::Model::LocalizedString

      @xml_mapping.instance_eval do
        root "item"
      end
    end
  end

  context "XML mapping" do
    it "with Text" do
      xml = <<~XML
        <item language="en" script="Latn" locale="US">Text</item>
      XML

      item = fake_class.from_xml xml
      expect(item.content).to be_instance_of Relaton::Model::LocalizedString::Content
      expect(item.language).to eq "en"
      expect(item.script).to eq "Latn"
      expect(item.locale).to eq "US"
      expect(item.to_xml).to be_equivalent_to xml
    end

    it "with Variants" do
      xml = <<~XML
        <item>
          <variant language="en" script="Latn" locale="US">Text</variant>
        </item>
      XML

      item = fake_class.from_xml xml
      expect(item.content).to be_instance_of Relaton::Model::LocalizedString::Variants
      expect(item.to_xml).to be_equivalent_to xml
    end
  end
end
