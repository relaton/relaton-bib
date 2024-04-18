RSpec.describe RelatonBib::ContributionInfo::Role do
  it "raises invalid type argument error" do
    expect { described_class.new type: "type" }.to output(
      /Contributor's type `type` is invalid/,
    ).to_stderr_from_any_process
  end
end
