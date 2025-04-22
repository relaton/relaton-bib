describe Relaton::Bib::Renderer::Rfc do
  let(:rfc) { Relaton::Bib::Renderer::Rfc.transform(item) }

  context "render reference group" do
    let(:item) { Relaton::Bib::Item.from_yaml File.read("spec/fixtures/bcp.yml") }
    let(:file) { "spec/fixtures/bcp.xml" }
    it do
      xml = rfc.to_xml
      File.write(file, xml, encoding: "UTF-8") unless File.exist? file
      expect(xml).to be_equivalent_to File.read(file, encoding: "UTF-8")
    end
  end

  context "rendet reference" do
    let(:item) { Relaton::Bib::Item.from_yaml File.read("spec/fixtures/rfc.yml") }
    let(:file) { "spec/fixtures/rfc.xml" }
    it do
      xml = rfc.to_xml
      File.write(file, xml, encoding: "UTF-8") unless File.exist? file
      expect(xml).to be_equivalent_to File.read(file, encoding: "UTF-8")
    end
  end
end
