describe Relaton::Bib::Organization do
  subject do
    described_class.new(
      name: "Org",
      abbreviation: "ORG",
      subdivision: [Relaton::Bib::LocalizedString.new(content: "Subdivision", language: "en")],
      identifier: [Relaton::Bib::Organization::Identifier.new(type: "uri", content: "http://example.com")],
      contact: [Relaton::Bib::Uri.new(type: "work", value: "http://example.com")],
      logo: Relaton::Bib::Image.new(id: "IMG", src: "http://example.com/logo.png", mimetype: "image/png"),
    )
  end

  context "==" do
    xit "same content" do
      other = described_class.new(
        name: "Org",
        abbreviation: "ORG",
        subdivision: [Relaton::Bib::LocalizedString.new(content: "Subdivision", language: "en")],
        identifier: [Relaton::Bib::Organization::Identifier.new(type: "uri", content: "http://example.com")],
        contact: [Relaton::Bib::Uri.new(type: "work", value: "http://example.com")],
        logo: Relaton::Bib::Image.new(id: "IMG", src: "http://example.com/logo.png", mimetype: "image/png"),
      )
      expect(subject).to eq other
    end

    it "different content" do
      other = described_class.new(
        name: "Org",
        abbreviation: "ORG",
        subdivision: [Relaton::Bib::LocalizedString.new(content: "Subdivision", language: "en")],
        identifier: [Relaton::Bib::Organization::Identifier.new(type: "uri", content: "http://example.com")],
        uri: [Relaton::Bib::Uri.new(type: "work", value: "http://example.com")],
      )
      expect(subject).not_to eq other
    end
  end
end

describe Relaton::Bib::Organization::Identifier do
  xit "raises invalid type argument error" do
    expect { Relaton::Bib::Organization::Identifier.new "type", "value" }.to raise_error ArgumentError
  end
end
