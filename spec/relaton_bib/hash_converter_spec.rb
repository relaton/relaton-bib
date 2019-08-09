RSpec.describe RelatonBib::HashConverter do
  it "warn if bibitem missig" do
    expect do
      ret = { relation: [type: "updates"] }
      RelatonBib::HashConverter.relation_bibitem_hash_to_bib ret, ret[:relation][0], 0
    end.to output(/bibitem missing/).to_stderr
  end
end
