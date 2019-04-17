RSpec.describe RelatonBib::Series do
  it "raise argument error" do
    expect { RelatonBib::Series.new }.to raise_error ArgumentError
  end
end
