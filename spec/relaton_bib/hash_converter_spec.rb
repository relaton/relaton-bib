RSpec.describe RelatonBib::HashConverter do
  it "warn if bibitem missig" do
    expect do
      ret = { relation: [type: "updates"] }
      RelatonBib::HashConverter.relation_bibitem_hash_to_bib ret, ret[:relation][0], 0
    end.to output(/bibitem missing/).to_stderr
  end

  it "make affiliation description form string" do
    affiliation = RelatonBib::HashConverter.affiliation_hash_to_bib(
      affiliation: { description: "Description", organization: { name: "Org" } },
    )
    expect(affiliation).to be_instance_of Array
    expect(affiliation.first).to be_instance_of RelatonBib::Affilation
  end

  it "make loalized string form hash" do
    ls = RelatonBib::HashConverter.localizedstring content: "string"
    expect(ls).to be_instance_of RelatonBib::LocalizedString
  end
end
