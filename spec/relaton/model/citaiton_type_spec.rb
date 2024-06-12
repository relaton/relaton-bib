describe Relaton::Model::CitationType do
  let(:dummy_class) do
    Class.new(Shale::Mapper) do
      prepend Relaton::Model::CitationType

      attribute :content, Relaton::Model::CitationType::Content

      @xml_mapping.instance_eval do
        root "dummy-element"
      end
    end
  end

  context "with locality" do
    let(:xml) do
      <<~XML
        <dummy-element bibitemid="ISO712">
          <locality type="section"><referenceFrom>1</referenceFrom></locality>
          <date>2001-01</date>
        </dummy-element>
      XML
    end

    it "from_xml" do
      item = dummy_class.from_xml xml
      expect(item.bibitemid).to eq "ISO712"
      expect(item.content).to be_instance_of Relaton::Model::CitationType::Content
      expect(item.to_xml).to be_equivalent_to xml
    end
  end

  context "with localityStack" do
    let(:xml) do
      <<~XML
        <dummy-element bibitemid="ISO712">
          <localityStack>
            <locality type="section"><referenceFrom>1</referenceFrom></locality>
            <locality type="clause"><referenceFrom>2</referenceFrom></locality>
          </localityStack>
          <date>2001-01</date>
        </dummy-element>
      XML
    end

    it "from_xml" do
      item = dummy_class.from_xml xml
      expect(item.bibitemid).to eq "ISO712"
      expect(item.content).to be_instance_of Relaton::Model::CitationType::Content
      expect(item.to_xml).to be_equivalent_to xml
    end
  end
end
