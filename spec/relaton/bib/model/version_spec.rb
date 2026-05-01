describe Relaton::Bib::Version do
  describe "XML round-trip" do
    it "parses new shape and re-emits it unchanged" do
      xml = '<version type="semver">1.2.0</version>'
      v = described_class.from_xml(xml)
      expect(v.content).to eq "1.2.0"
      expect(v.type).to eq "semver"
      expect(v.to_xml).to eq xml
    end

    it "joins both legacy children into content" do
      xml = "<version><revision-date>1994-01-01</revision-date>" \
            "<draft>PD</draft></version>"
      v = described_class.from_xml(xml)
      expect(v.content).to eq "PD (1994-01-01)"
      expect(v.to_xml).to eq "<version>PD (1994-01-01)</version>"
    end

    it "parses legacy shape with revision-date only" do
      xml = "<version><revision-date>2019-04-01</revision-date></version>"
      v = described_class.from_xml(xml)
      expect(v.content).to eq "2019-04-01"
      expect(v.to_xml).to eq "<version>2019-04-01</version>"
    end

    it "parses legacy shape with draft only" do
      v = described_class.from_xml("<version><draft>2.0.0</draft></version>")
      expect(v.content).to eq "2.0.0"
      expect(v.to_xml).to eq "<version>2.0.0</version>"
    end
  end

  describe "YAML round-trip" do
    it "parses new shape and re-emits it" do
      v = described_class.from_yaml("---\ntype: semver\ncontent: 1.2.0\n")
      expect(v.content).to eq "1.2.0"
      expect(v.type).to eq "semver"
    end

    it "parses legacy keys and folds them into content" do
      yaml = "---\nrevision_date: '1994-01-01'\ndraft: PD\n"
      v = described_class.from_yaml(yaml)
      expect(v.content).to eq "PD (1994-01-01)"
      expect(v.to_yaml).to eq "---\ncontent: PD (1994-01-01)\n"
    end

    it "parses legacy revision_date only" do
      v = described_class.from_yaml("---\nrevision_date: '2019-04-01'\n")
      expect(v.content).to eq "2019-04-01"
    end

    it "parses legacy draft only" do
      v = described_class.from_yaml("---\ndraft: '2.0.0'\n")
      expect(v.content).to eq "2.0.0"
    end
  end

  describe "legacy field accessors" do
    it "always returns nil so legacy fields never serialize back" do
      xml = "<version><revision-date>1994-01-01</revision-date>" \
            "<draft>PD</draft></version>"
      v = described_class.from_xml(xml)
      expect(v.revision_date).to be_nil
      expect(v.draft).to be_nil
    end
  end
end
