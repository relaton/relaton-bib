describe Relaton::Bib::StructuredIdentifier do
  it "remove data for Chinise Standard" do
    sid = described_class.new docnumber: "TEST-1999", type: "Chinese Standard"
    sid.remove_date
    expect(sid.docnumber).to eq "TEST"
  end
end
