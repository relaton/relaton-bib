describe Relaton::Bib::Bibdata do
  let(:input_xml) { File.read "spec/fixtures/bibdata_item.xml", encoding: "UTF-8" }
  let(:item) { described_class.from_xml input_xml }

  context "round trip" do
    it "to XML" do
      expect(described_class.to_xml(item)).to be_equivalent_to input_xml
    end
  end
end
