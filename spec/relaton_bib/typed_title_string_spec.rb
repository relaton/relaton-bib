RSpec.describe RelatonBib::TypedTitleString do
  it "raises invalid type argument error" do
    expect { RelatonBib::TypedTitleString.new type: "type" }.to raise_error ArgumentError
  end

  it "raises missed title or content argument error" do
    expect { RelatonBib::TypedTitleString.new }.to raise_error ArgumentError
  end
end
