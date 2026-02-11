describe Relaton::Bib::Converter::Asciibib do
  it "convert item to AsciiBib" do
    item = Relaton::Bib::Item.from_yaml File.read("spec/fixtures/item.yaml", encoding: "UTF-8")
    file = "spec/fixtures/asciibib.adoc"
    bib = item.to_asciibib
    File.write file, bib, encoding: "UTF-8" unless File.exist? file
    expect(bib).to eq File.read(file, encoding: "UTF-8")
  end
end
