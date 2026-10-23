describe Relaton::Bib::Bibitem do
  context "XML" do
    let(:file) { "spec/fixtures/bibitem.xml" }
    let(:input_xml) { File.read(file, encoding: "UTF-8") }
    let(:item) { described_class.from_xml input_xml }

    it "round trip" do
      expect(described_class.to_xml(item)).to be_equivalent_to input_xml
      schema = Jing.new "spec/schemas/biblio-compile.rng"
      errors = schema.validate file
      expect(errors).to eq []
    end
  end

  context "multiple formattedref (bilingual bibdata, GB)" do
    let(:xml) do
      <<~XML
        <bibitem id="GB5055" type="standard">
          <formattedref>现行国家标准</formattedref>
          <formattedref>Code of practice</formattedref>
          <title language="zh" script="Hans">谷物和豆类</title>
          <docidentifier type="GB" primary="true">GB 5055</docidentifier>
        </bibitem>
      XML
    end

    it "collapses to the leading formattedref" do
      item = described_class.from_xml xml
      expect(item.formattedref.content).to eq "现行国家标准"
    end

    it "round trips through serialization" do
      item = described_class.from_xml xml
      out = described_class.to_xml(item)
      expect(out.scan("<formattedref>").size).to eq 1
    end
  end
end
