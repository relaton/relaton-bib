RSpec.describe RelatonBib::HashConverter do
  before(:each) { RelatonBib.instance_variable_set :@configuration, nil }

  it "warn if bibitem missig" do
    expect do
      ret = { relation: [type: "updates"] }
      RelatonBib::HashConverter.relation_bibitem_hash_to_bib ret[:relation][0]
    end.to output(/bibitem missing/).to_stderr
  end

  it "make affiliation description from string" do
    affiliation = RelatonBib::HashConverter.affiliation_hash_to_bib(
      affiliation: {
        description: "Description", organization: { name: "Org" }
      },
    )
    expect(affiliation).to be_instance_of Array
    expect(affiliation.first).to be_instance_of RelatonBib::Affiliation
  end

  it "make localized string from hash" do
    ls = RelatonBib::HashConverter.localizedstring content: "string"
    expect(ls).to be_instance_of RelatonBib::LocalizedString
  end

  it "make localityStack form unwrapped loclaity" do
    hash = { locality: [{ type: "section", reference_from: "1" }] }
    RelatonBib::HashConverter.relation_locality_hash_to_bib hash
    expect(hash[:locality].first).to be_instance_of RelatonBib::LocalityStack
  end

  it "make sourceLocalityStack form unwrapped sourceLoclaity" do
    hash = { source_locality: [{ type: "section", reference_from: "1" }] }
    RelatonBib::HashConverter.relation_source_locality_hash_to_bib hash
    expect(hash[:source_locality].first).to be_instance_of(
      RelatonBib::SourceLocalityStack,
    )
  end

  it "parse validity time" do
    r = RelatonBib::HashConverter.parse_validity_time({ begins: 1999 }, :begins)
    expect(r.to_s).to match(/^1999-01-01/)
    r = RelatonBib::HashConverter.parse_validity_time({ ends: 1999 }, :ends)
    expect(r.to_s).to match(/^1999-12-31/)
    r = RelatonBib::HashConverter.parse_validity_time(
      { begins: "1999-02" }, :begins
    )
    expect(r.to_s).to match(/^1999-02-01/)
    r = RelatonBib::HashConverter.parse_validity_time(
      { ends: "1999-02" }, :ends
    )
    expect(r.to_s).to match(/^1999-02-28/)
  end

  context "contacts_hash_to_bib" do
    it "create address form old hash" do
      hash = { contact: [{ street: "Street", city: "City", country: "Country" }] }
      address = described_class.contacts_hash_to_bib hash
      expect(address).to be_instance_of Array
      expect(address.first).to be_instance_of RelatonBib::Address
      expect(address.first.street).to eq ["Street"]
      expect(address.first.city).to eq "City"
      expect(address.first.country).to eq "Country"
    end

    it "create formatted address" do
      entity = { contact: [{ address: { formatted_address: "Address" } }] }
      address = RelatonBib::HashConverter.contacts_hash_to_bib entity
      expect(address).to be_instance_of Array
      expect(address.first).to be_instance_of RelatonBib::Address
      expect(address.first.formatted_address).to eq "Address"
    end

    it "create contact form old hash" do
      hash = { contact: [{ type: "phone", value: "123" }] }
      contact = described_class.contacts_hash_to_bib hash
      expect(contact).to be_instance_of Array
      expect(contact.first).to be_instance_of RelatonBib::Contact
      expect(contact.first.type).to eq "phone"
      expect(contact.first.value).to eq "123"
    end

    it "create phone" do
      hash = { contact: [{ phone: "223322", type: "mobile" }] }
      contact = described_class.contacts_hash_to_bib hash
      expect(contact).to be_instance_of Array
      expect(contact.first).to be_instance_of RelatonBib::Contact
      expect(contact.first.type).to eq "phone"
      expect(contact.first.subtype).to eq "mobile"
      expect(contact.first.value).to eq "223322"
    end
  end

  it "create copyright" do
    ret = {
      copyright: {
        owner: {
          name: [{ content: "Owner Name" }], abbreviation: { content: "ABBR" },
          contact: [{ uri: "http://example.com" }]
        },
        from: "2022",
      },
    }
    copyright = described_class.copyright_hash_to_bib ret
    expect(copyright).to be_instance_of Array
    expect(copyright[0][:owner][0][:name][0][:content]).to eq "Owner Name"
    expect(copyright[0][:owner][0][:abbreviation][:content]).to eq "ABBR"
    expect(copyright[0][:owner][0][:contact][0]).to be_instance_of RelatonBib::Contact
    expect(copyright[0][:owner][0][:contact][0].type).to eq "uri"
    expect(copyright[0][:owner][0][:contact][0].value).to eq "http://example.com"
  end

  context "create doctype" do
    it "from string" do
      ret = { doctype: "Doctype" }
      described_class.doctype_hash_to_bib ret
      expect(ret[:doctype]).to be_instance_of RelatonBib::DocumentType
      expect(ret[:doctype].type).to eq "Doctype"
      expect(ret[:doctype].abbreviation).to be_nil
    end

    it "from hash" do
      ret = { doctype: { type: "Doctype", abbreviation: "DCT" } }
      described_class.doctype_hash_to_bib ret
      expect(ret[:doctype]).to be_instance_of RelatonBib::DocumentType
      expect(ret[:doctype].type).to eq "Doctype"
      expect(ret[:doctype].abbreviation).to eq "DCT"
    end
  end
end
