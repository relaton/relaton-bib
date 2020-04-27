RSpec.describe RelatonBib::DocumentRelation do
  it "warn when type is invalid" do
    expect do
      RelatonBib::DocumentRelation.new type: "invalid", bibitem: nil
    end.to output(/invalid relation type/).to_stderr
  end
end
