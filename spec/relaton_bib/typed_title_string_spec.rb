RSpec.describe RelatonBib::TypedTitleString do
  it "raises invalid type argument error" do
    expect do
      RelatonBib::TypedTitleString.new type: "type"
    end.to raise_error ArgumentError
  end

  it "raises missed title or content argument error" do
    expect { RelatonBib::TypedTitleString.new }.to raise_error ArgumentError
  end

  it "create instance without exeption" do
    title = RelatonBib::TypedTitleString.new(
      title: RelatonBib::FormattedString.new(content: "Title"),
    )
    expect(title).to be_instance_of RelatonBib::TypedTitleString
  end
end
