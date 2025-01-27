RSpec.describe RelatonBib do
  it "has a version number" do
    expect(RelatonBib::VERSION).not_to be nil
  end

  it "returns grammar hash" do
    hash = RelatonBib.grammar_hash
    expect(hash).to be_instance_of String
    expect(hash.size).to eq 32
  end

  context "parse date" do
    it "February 2012" do
      expect(RelatonBib.parse_date("February 2012")).to eq "2012-02"
      expect(RelatonBib.parse_date("February 2012", false)).to eq Date.new(2012, 2, 1)
    end

    it "February 11, 2012" do
      expect(RelatonBib.parse_date("February 11, 2012")).to eq "2012-02-11"
      expect(RelatonBib.parse_date("February 11, 2012", false)).to eq Date.new(2012, 2, 11)
    end

    it "2012-02-11" do
      expect(RelatonBib.parse_date("2012-02-11")).to eq "2012-02-11"
      expect(RelatonBib.parse_date("2012-02-11", false)).to eq Date.new(2012, 2, 11)
    end

    it "2012-2-3" do
      expect(RelatonBib.parse_date("2012-2-3")).to eq "2012-02-03"
      expect(RelatonBib.parse_date("2012-2-3", false)).to eq Date.new(2012, 2, 3)
    end

    it "2012-02" do
      expect(RelatonBib.parse_date("2012-02")).to eq "2012-02"
      expect(RelatonBib.parse_date("2012-02", false)).to eq Date.new(2012, 2, 1)
    end

    it "2012-2" do
      expect(RelatonBib.parse_date("2012-2")).to eq "2012-02"
      expect(RelatonBib.parse_date("2012-2", false)).to eq Date.new(2012, 2, 1)
    end

    it "invalid date" do
      expect do
        expect(RelatonBib.parse_date("2012-02-31")).to eq "2012-02-31"
      end.to output(/invalid date/).to_stderr_from_any_process
    end
  end

  it "parse YAML with an old version of Psych" do
    method = double "params"
    expect(method).to receive(:parameters).and_return [%i[req yaml]]
    expect(YAML).to receive(:method).with(:safe_load).and_return method
    expect(YAML).to receive(:safe_load).with(kind_of(String), [], symbolize_names: false).and_return({})
    RelatonBib.parse_yaml "key: value"
  end

  it "parse YAML with a new version of Psych" do
    method = double "params"
    expect(method).to receive(:parameters).and_return [%i[req yaml permitted_classes]]
    expect(YAML).to receive(:method).with(:safe_load).and_return method
    expect(YAML).to receive(:safe_load)
      .with(kind_of(String), permitted_classes: [], symbolize_names: false)
      .and_return({})
    RelatonBib.parse_yaml "key: value"
  end
end
