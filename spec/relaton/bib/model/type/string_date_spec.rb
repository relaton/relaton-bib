describe Relaton::Bib::StringDate do
  describe ".cast" do
    it "parses valid date" do
      sd = described_class.cast("August 15, 2021")
      expect(sd.to_s).to eq "2021-08-15"
    end

    it "returns nil for invalid date" do
      sd = described_class::Value.parse_date("invalid-date")
      expect(sd).to be_nil
    end
  end

  describe "#to_date" do
    context "valid date" do
      it "returns Date object" do
        sd = described_class.cast("2020-05-01")
        expect(sd.to_date).to eq Date.new(2020, 5, 1)
      end
    end
  end
end
