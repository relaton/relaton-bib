describe Relaton::Bib::Locality do
  it "warn if locality type is invalid" do
    expect do
      described_class.new "type", "from"
    end.to output(/invalid locality type/).to_stderr
  end
end
