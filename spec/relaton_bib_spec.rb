RSpec.describe RelatonBib do
  it "has a version number" do
    expect(RelatonBib::VERSION).not_to be nil
  end

  context "parse date" do
    it "February 2012" do
      expect(RelatonBib.parse_date("February 2012").to_s).to eq "2012-02-01"
    end

    it "February 11, 2012" do
      expect(RelatonBib.parse_date("February 11, 2012").to_s).to eq "2012-02-11"
    end

    it "2012-02-11" do
      expect(RelatonBib.parse_date("2012-02-11").to_s).to eq "2012-02-11"
    end

    it "2012-02" do
      expect(RelatonBib.parse_date("2012-02").to_s).to eq "2012-02-01"
    end
  end
end
