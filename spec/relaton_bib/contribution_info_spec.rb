RSpec.describe RelatonBib::ContributorRole do
  it "raises invalid type argument error" do
    expect { RelatonBib::ContributorRole.new type: "type" }.to output(
      /Contributor's type "type" is invalid/
    ).to_stderr
  end
end
