describe Relaton::Bib::Bibitem do
  context "XML" do
    let(:file) { "spec/fixtures/bibitem.xml" }
    let(:input_xml) { File.read(file, encoding: "UTF-8") }
    let(:item) { described_class.from_xml input_xml }

    it "round trip" do
      expect(described_class.to_xml(item)).to be_equivalent_to input_xml
      schema = Jing.new "grammars/biblio-compile.rng"
      errors = schema.validate file
      expect(errors).to eq []
    end
  end
end
