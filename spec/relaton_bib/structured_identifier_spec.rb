RSpec.describe RelatonBib::StructuredIdentifier do
  it "remove data for Chinise Standard" do
    sid = RelatonBib::StructuredIdentifier.new docnumber: "TEST-1999", type: "Chinese Standard"
    sid.remove_date
    expect(sid.docnumber).to eq "TEST"
  end
end
