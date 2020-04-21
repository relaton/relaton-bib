RSpec.describe RelatonBib::BibItemLocality do
  it "warn if locality type is invalid" do
    expect do
      RelatonBib::BibItemLocality.new "type", "from"
    end.to output(/invalid locality type/).to_stderr
  end
end
