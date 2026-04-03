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

  describe "ToAsciibib#render_edition" do
    let(:item) { Relaton::Bib::ItemData.new }
    let(:converter) { Relaton::Bib::Converter::Asciibib::ToAsciibib.new(item) }

    it "renders edition with number only (no content)" do
      item.edition = Relaton::Bib::Edition.new(number: "2")
      result = converter.send(:render_edition)
      expect(result).to eq "edition.number:: 2\n"
    end

    it "renders empty string when edition has neither content nor number" do
      item.edition = Relaton::Bib::Edition.new
      result = converter.send(:render_edition)
      expect(result).to eq ""
    end
  end

  describe "ToAsciibib#render_person_identifier" do
    let(:item) { Relaton::Bib::ItemData.new }
    let(:converter) { Relaton::Bib::Converter::Asciibib::ToAsciibib.new(item) }

    it "renders identifier with type only, single item" do
      id = Relaton::Bib::Person::Identifier.new(type: "isni")
      result = converter.send(
        :render_person_identifier,
        id,
        "person",
        1,
      )
      expect(result).to eq "person.identifier.type:: isni\n"
    end

    it "renders identifier with type only, multiple items" do
      id = Relaton::Bib::Person::Identifier.new(type: "isni")
      result = converter.send(
        :render_person_identifier,
        id,
        "person",
        2,
      )
      expected = "person.identifier::\n" \
                 "person.identifier.type:: isni\n"
      expect(result).to eq expected
    end
  end

  describe "ToAsciibib#render_org_identifier" do
    let(:item) { Relaton::Bib::ItemData.new }
    let(:converter) do
      Relaton::Bib::Converter::Asciibib::ToAsciibib.new(item)
    end

    it "renders identifier with type only, single item" do
      id = Relaton::Bib::OrganizationType::Identifier.new(
        type: "uri",
      )
      result = converter.send(
        :render_org_identifier,
        id,
        "org",
        1,
      )
      expect(result).to eq "org.identifier.type:: uri\n"
    end

    it "renders identifier with type only, multiple items" do
      id = Relaton::Bib::OrganizationType::Identifier.new(
        type: "uri",
      )
      result = converter.send(
        :render_org_identifier,
        id,
        "org",
        2,
      )
      expected = "org.identifier::\n" \
                 "org.identifier.type:: uri\n"
      expect(result).to eq expected
    end
  end

  describe "ToAsciibib#render_localized_string" do
    let(:item) { Relaton::Bib::ItemData.new }
    let(:converter) { Relaton::Bib::Converter::Asciibib::ToAsciibib.new(item) }

    it "renders localized string with language but no content" do
      ls = Relaton::Bib::LocalizedString.new(language: "en")
      result = converter.send(:render_localized_string, ls, "title")
      expect(result).to eq "title.language:: en\n"
    end

    it "renders localized string with script but no content" do
      ls = Relaton::Bib::LocalizedString.new(script: "Latn")
      result = converter.send(:render_localized_string, ls, "title")
      expect(result).to eq "title.script:: Latn\n"
    end

    it "renders localized string with has_attrs but no content" do
      ls = Relaton::Bib::LocalizedString.new
      result = converter.send(:render_localized_string, ls, "title", 1, true)
      expect(result).to eq ""
    end
  end
end
