describe RelatonBib::Place do
  it "raise ArgumentError" do
    expect do
      described_class.new
    end.to raise_error ArgumentError
  end
end
