RSpec.describe RelatonBib::ContributorRole do
  it "raises invalid type argument error" do
    expect { RelatonBib::ContributorRole.new "type" }.to raise_error ArgumentError
  end
end
