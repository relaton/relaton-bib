describe "RFC Parser" do
  context "Reference XML roundtrip" do
    let(:input) { File.read "spec/fixtures/rfc.xml", encoding: "utf-8" }
    let(:item) { Relaton::Bib::Parser::RfcReference.from_xml input }
    subject { Relaton::Bib::Renderer::Rfc.transform(item).to_xml }
    it { is_expected.to be_equivalent_to input }
  end

  context "ReferenceGroup XML roundtrip" do
    let(:input) { File.read "spec/fixtures/bcp.xml", encoding: "utf-8" }
    let(:item) { Relaton::Bib::Parser::RfcReferencegroup.from_xml input }
    subject { Relaton::Bib::Renderer::Rfc.transform(item).to_xml }
    it do
      is_expected.to be_equivalent_to input
    end
  end
end
