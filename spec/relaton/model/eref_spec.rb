describe Relaton::Model::Eref do
  context "with locality" do
    let(:xml) do
      <<~XML
        <eref normative="true" citeas="ISO 712" type="inline" alt="alt" bibitemid="ISO712">
          <locality type="section"><referenceFrom>1</referenceFrom></locality>
          <date>2001-01</date>
        </eref>
      XML
    end

    it "from XML" do
      eref = described_class.from_xml xml
      expect(eref).to be_instance_of Relaton::Model::Eref
      expect(eref.normative).to be true
      expect(eref.citeas).to eq "ISO 712"
      expect(eref.type).to eq "inline"
      expect(eref.alt).to eq "alt"
      expect(eref.bibitemid).to eq "ISO712"
      expect(eref.content).to be_instance_of Relaton::Model::CitationType::Content
      expect(eref.to_xml).to be_equivalent_to xml
    end
  end

  context "with localityStack" do
    let(:xml) do
      <<~XML
        <eref normative="true" citeas="ISO 712" type="inline" alt="alt" bibitemid="ISO712">
          <localityStack>
            <locality type="section"><referenceFrom>1</referenceFrom></locality>
            <locality type="clause"><referenceFrom>2</referenceFrom></locality>
          </localityStack>
          <date>2001-01</date>
        </eref>
      XML
    end

    it "from XML" do
      eref = described_class.from_xml xml
      expect(eref).to be_instance_of Relaton::Model::Eref
      expect(eref.normative).to be true
      expect(eref.citeas).to eq "ISO 712"
      expect(eref.type).to eq "inline"
      expect(eref.alt).to eq "alt"
      expect(eref.bibitemid).to eq "ISO712"
      expect(eref.content).to be_instance_of Relaton::Model::CitationType::Content
      expect(eref.to_xml).to be_equivalent_to xml
    end
  end
end
