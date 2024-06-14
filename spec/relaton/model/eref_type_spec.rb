describe Relaton::Model::ErefType do
  let(:doc) { Shale::Adapter::Nokogiri::Document.new }

  let(:dummy_class) do
    Class.new(Shale::Mapper) do
      include Relaton::Model::ErefType

      @xml_mapping.instance_eval do
        root "dummy-element"
      end
    end
  end

  let(:xml) do
    <<~XML
      <dummy-element bibitemid="ISO712">
        <locality type="section"><referenceFrom>1</referenceFrom></locality>
        <locality type="clause"><referenceFrom>2</referenceFrom></locality>
        <date>2001-01</date>
        Text
        <em>Em</em>
      </dummy-element>
    XML
  end

  it "from_xml" do
    item = dummy_class.from_xml xml
    expect(item.bibitemid).to eq "ISO712"
    expect(item.content).to be_instance_of Relaton::Model::ErefType::Content
    expect(item.to_xml).to be_equivalent_to xml
  end
end
