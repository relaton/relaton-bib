RSpec.describe RelatonBib::DocumentRelation do
  it "warn when type is invalid" do
    expect do
      RelatonBib::DocumentRelation.new type: "invalid", bibitem: nil
    end.to output(/Invalid relation type/).to_stderr_from_any_process
  end
end
