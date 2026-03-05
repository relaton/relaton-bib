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

  describe "comparison" do
    let(:date_2020) { described_class.cast("2020") }
    let(:date_2021) { described_class.cast("2021") }
    let(:date_2021_01) { described_class.cast("2021-01") }
    let(:date_2021_06) { described_class.cast("2021-06") }
    let(:date_2021_06_15) { described_class.cast("2021-06-15") }
    let(:date_2021_06_20) { described_class.cast("2021-06-20") }

    it "compares year dates" do
      expect(date_2020).to be < date_2021
      expect(date_2021).to be > date_2020
    end

    it "compares year-month dates" do
      expect(date_2021_01).to be < date_2021_06
    end

    it "compares full dates" do
      expect(date_2021_06_15).to be < date_2021_06_20
    end

    it "compares dates with different precision" do
      expect(date_2020).to be < date_2021_06
      expect(date_2021).to be < date_2021_01
    end

    it "returns true for equal dates" do
      other = described_class.cast("2021-06-15")
      expect(date_2021_06_15).to eq other
    end

    it "returns nil when comparing with non-Value" do
      expect(date_2021 <=> "2021").to be_nil
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
