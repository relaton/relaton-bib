describe Relaton::Bib do
  it "has a version number" do
    expect(Relaton::Bib::VERSION).not_to be nil
  end

  xit "returns grammar hash" do
    hash = Relaton::Bib.grammar_hash
    expect(hash).to be_instance_of String
    expect(hash.size).to eq 32
  end

  context "parse date" do
    xit "February 2012" do
      expect(Relaton::Bib.parse_date("February 2012")).to eq "2012-02"
      expect(Relaton::Bib.parse_date("February 2012", false)).to eq Date.new(2012, 2, 1)
    end

    xit "February 11, 2012" do
      expect(Relaton::Bib.parse_date("February 11, 2012")).to eq "2012-02-11"
      expect(Relaton::Bib.parse_date("February 11, 2012", false)).to eq Date.new(2012, 2, 11)
    end

    xit "2012-02-11" do
      expect(Relaton::Bib.parse_date("2012-02-11")).to eq "2012-02-11"
      expect(Relaton::Bib.parse_date("2012-02-11", false)).to eq Date.new(2012, 2, 11)
    end

    xit "2012-2-3" do
      expect(Relaton::Bib.parse_date("2012-2-3")).to eq "2012-02-03"
      expect(Relaton::Bib.parse_date("2012-2-3", false)).to eq Date.new(2012, 2, 3)
    end

    xit "2012-02" do
      expect(Relaton::Bib.parse_date("2012-02")).to eq "2012-02"
      expect(Relaton::Bib.parse_date("2012-02", false)).to eq Date.new(2012, 2, 1)
    end

    xit "2012-2" do
      expect(Relaton::Bib.parse_date("2012-2")).to eq "2012-02"
      expect(Relaton::Bib.parse_date("2012-2", false)).to eq Date.new(2012, 2, 1)
    end
  end

  it "parse YAML with an old version of Psych" do
    method = double "params"
    expect(method).to receive(:parameters).and_return [%i[req yaml]]
    expect(YAML).to receive(:method).with(:safe_load).and_return method
    expect(YAML).to receive(:safe_load).with(kind_of(String), [], symbolize_names: false).and_return({})
    Relaton.parse_yaml "key: value"
  end

  it "parse YAML with a new version of Psych" do
    method = double "params"
    expect(method).to receive(:parameters).and_return [%i[req yaml permitted_classes]]
    expect(YAML).to receive(:method).with(:safe_load).and_return method
    expect(YAML).to receive(:safe_load)
      .with(kind_of(String), permitted_classes: [], symbolize_names: false)
      .and_return({})
    Relaton.parse_yaml "key: value"
  end
end
