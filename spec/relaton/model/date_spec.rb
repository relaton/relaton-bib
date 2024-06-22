describe Relaton::Model::Date do
  it "from XML" do
    date = described_class.from_xml "<date>2001-01</date>"
    expect(date.content).to eq "2001-01"
  end

  it "to XML" do
    date = described_class.new
    date.content = "2001-01"
    expect(date.to_xml.to_s).to be_equivalent_to "<date>2001-01</date>"
  end
end
