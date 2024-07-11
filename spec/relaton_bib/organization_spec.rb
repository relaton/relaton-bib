describe RelatonBib::Organization do
  subject do
    described_class.new(
      name: "Org",
      abbreviation: "ORG",
      subdivision: [RelatonBib::LocalizedString.new("Subdivision", "en")],
      url: "http://example.com",
      identifier: [RelatonBib::OrgIdentifier.new("uri", "http://example.com")],
      contact: [RelatonBib::Contact.new(type: "work", value: "http://example.com")],
      logo: RelatonBib::Image.new(id: "IMG", src: "http://example.com/logo.png", mimetype: "image/png")
    )
  end

  context "==" do
    it "same content" do
      other = described_class.new(
        name: "Org",
        abbreviation: "ORG",
        subdivision: [RelatonBib::LocalizedString.new("Subdivision", "en")],
        url: "http://example.com",
        identifier: [RelatonBib::OrgIdentifier.new("uri", "http://example.com")],
        contact: [RelatonBib::Contact.new(type: "work", value: "http://example.com")],
        logo: RelatonBib::Image.new(id: "IMG", src: "http://example.com/logo.png", mimetype: "image/png")
      )
      expect(subject).to eq other
    end

    it "different content" do
      other = described_class.new(
        name: "Org",
        abbreviation: "ORG",
        subdivision: [RelatonBib::LocalizedString.new("Subdivision", "en")],
        url: "http://example.com",
        identifier: [RelatonBib::OrgIdentifier.new("uri", "http://example.com")],
        contact: [RelatonBib::Contact.new(type: "work", value: "http://example.com")]
      )
      expect(subject).not_to eq other
    end
  end
end

describe RelatonBib::OrgIdentifier do
  # it "raises invalid type argument error" do
  #   expect { RelatonBib::OrgIdentifier.new "type", "value" }.to raise_error ArgumentError
  # end
end
