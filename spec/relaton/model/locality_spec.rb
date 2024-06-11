describe Relaton::Model::Locality do
  let(:xml) do
    '<locality type="page"><referenceFrom>1</referenceFrom><referenceTo>4</referenceTo></locality>'
  end

  it "from XML" do
    locality = described_class.from_xml xml
    expect(locality).to be_instance_of Relaton::Bib::Locality
    expect(locality.type).to eq "page"
    expect(locality.reference_from.content).to eq "1"
    expect(locality.reference_to.content).to eq "4"
  end

  it "to XML" do
    locality = Relaton::Bib::Locality.new
    locality.type = "page"
    reference_from = Relaton::Model::ReferenceFrom.new content: "1"
    locality.reference_from = reference_from
    reference_to = Relaton::Model::ReferenceTo.new content: "4"
    locality.reference_to = reference_to
    expect(described_class.to_xml((locality))).to be_equivalent_to xml
  end
end
