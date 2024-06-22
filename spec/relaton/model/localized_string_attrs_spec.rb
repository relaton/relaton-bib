describe Relaton::Model::LocalizedStringAttrs do
  let(:fake_class) do
    Class.new(Shale::Mapper) do
      include Relaton::Model::LocalizedStringAttrs

      attribute :content, Shale::Type::String

      @xml_mapping.instance_eval do
        root "content"
        map_content to: :content
      end
    end
  end

  it "parse & render" do
    xml = <<~XML
      <content language="en" locale="US" script="Latn">text</content>
    XML
    item = fake_class.from_xml xml
    expect(item.content).to eq "text"
    expect(item.language).to eq "en"
    expect(item.locale).to eq "US"
    expect(item.script).to eq "Latn"
    expect(item.to_xml).to be_equivalent_to xml
  end
end
