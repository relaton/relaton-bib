describe Relaton::Bib::CopyrightAssociation do
  it "raise error if owners is empty" do
    expect do
      described_class.new owner: [], from: "2019"
    end.to raise_error ArgumentError
  end
end
