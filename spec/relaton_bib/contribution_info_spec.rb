RSpec.describe RelatonBib::ContributorRole do
  before(:each) do
    RelatonBib.instance_variable_set :@configuration, nil
  end

  it "raises invalid type argument error" do
    expect { RelatonBib::ContributorRole.new type: "type" }.to output(
      /Contributor's type `type` is invalid/,
    ).to_stderr_from_any_process
  end
end
