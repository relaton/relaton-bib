describe Relaton::Bib::LocalityStack do
  it "from XML" do
    xml = <<~XML
      <localityStack connective="or">
        <locality type="part"><referenceFrom>1</referenceFrom></locality>
        <locality type="page"><referenceFrom>4</referenceFrom></locality>
      </localityStack>
    XML
    locality_stack = described_class.from_xml xml
    expect(locality_stack).to be_instance_of Relaton::Bib::LocalityStack
    expect(locality_stack.connective).to eq "or"
    expect(locality_stack.locality.size).to eq 2
    expect(locality_stack.locality.first.type).to eq "part"
    expect(locality_stack.locality.first.reference_from).to eq "1"
    expect(locality_stack.locality.last.type).to eq "page"
    expect(locality_stack.locality.last.reference_from).to eq "4"
    expect(described_class.to_xml(locality_stack)).to be_equivalent_to xml
  end
end
