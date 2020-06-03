RSpec.describe RelatonBib::CopyrightAssociation do
  it "raise error if owners is empty" do
    expect do
      RelatonBib::CopyrightAssociation.new owner: [], from: "2019"
    end.to raise_error ArgumentError
  end
end
