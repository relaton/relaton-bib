RSpec.describe RelatonBib::HashConverter do
  it "warn if bibitem missig" do
    expect do
      ret = { relation: [type: "updates"] }
      RelatonBib::HashConverter.relation_bibitem_hash_to_bib ret[:relation][0]
    end.to output(/bibitem missing/).to_stderr
  end

  it "make affiliation description from string" do
    affiliation = RelatonBib::HashConverter.affiliation_hash_to_bib(
      affiliation: { description: "Description", organization: { name: "Org" } },
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
    expect(hash[:source_locality].first).to be_instance_of RelatonBib::SourceLocalityStack
  end
end
