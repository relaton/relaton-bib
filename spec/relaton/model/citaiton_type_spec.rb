describe Relaton::Model::CitationType do
  let(:dummy_class) do
    Class.new(Shale::Mapper) do
      include Relaton::Model::CitationType

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
      expect(item.locality).to be_instance_of Array
      expect(item.locality.size).to eq 1
      expect(item.locality.first).to be_instance_of Relaton::Bib::Locality
      expect(item.date).to eq "2001-01"
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
      expect(item.locality_stack).to be_instance_of Array
      expect(item.locality_stack.size).to eq 1
      expect(item.locality_stack.first).to be_instance_of Relaton::Bib::LocalityStack
      expect(item.date).to eq "2001-01"
      expect(item.to_xml).to be_equivalent_to xml
    end
  end
end
