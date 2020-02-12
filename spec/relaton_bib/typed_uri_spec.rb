RSpec.describe RelatonBib::TypedUri do
  it "set content" do
    uri = RelatonBib::TypedUri.new type: "src", content: nil
    uri.content = "http://example.com"
    expect(uri.content).to be_instance_of Addressable::URI
    expect(uri.content.to_s).to eq "http://example.com"
  end
end
