describe Relaton::Bib::StringDate do
  it "#to_date" do
    sd = described_class.cast("2020-05-01")
    expect(sd.to_date).to eq Date.new(2020, 5, 1)
    sd2 = described_class.cast("invalid-date")
    expect(sd2.to_date).to be_nil
  end
end
