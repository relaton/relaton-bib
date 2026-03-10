describe Relaton::Bib::Converter::Asciibib do
  it "convert item to AsciiBib" do
    item = Relaton::Bib::Item.from_yaml File.read("spec/fixtures/item.yaml", encoding: "UTF-8")
    file = "spec/fixtures/asciibib.adoc"
    bib = item.to_asciibib
    File.write file, bib, encoding: "UTF-8" unless File.exist? file
    expect(bib).to eq File.read(file, encoding: "UTF-8")
  end

  describe "ToAsciibib#render_edition_nested" do
    let(:item) { Relaton::Bib::ItemData.new }
    let(:converter) { Relaton::Bib::Converter::Asciibib::ToAsciibib.new(item) }

    it "renders edition with number and empty prefix" do
      edition = Relaton::Bib::Edition.new(content: "second", number: "2")
      result = converter.send(:render_edition_nested, edition, "")
      expect(result).to eq "edition.content:: second\nedition.number:: 2\n"
    end

    it "renders edition without number and empty prefix" do
      edition = Relaton::Bib::Edition.new(content: "second")
      result = converter.send(:render_edition_nested, edition, "")
      expect(result).to eq "edition.content:: second\n"
    end

    it "renders edition with number and non-empty prefix" do
      edition = Relaton::Bib::Edition.new(content: "third", number: "3")
      result = converter.send(:render_edition_nested, edition, "bibitem")
      expect(result).to eq "bibitem.edition.content:: third\nbibitem.edition.number:: 3\n"
    end

    it "renders edition without number and non-empty prefix" do
      edition = Relaton::Bib::Edition.new(content: "third")
      result = converter.send(:render_edition_nested, edition, "bibitem")
      expect(result).to eq "bibitem.edition.content:: third\n"
    end
  end
end
