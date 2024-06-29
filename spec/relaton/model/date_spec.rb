describe Relaton::Model::Date do
  context "parse XML" do
    it "from and to" do
      xml = <<~XML
        <date type="published" text="str"><from>2020-01-01</from><to>2020-01-02</to></date>
      XML
      doc = described_class.from_xml xml
      expect(doc.type).to eq "published"
      expect(doc.text).to eq "str"
      expect(doc.from).to eq "2020-01-01"
      expect(doc.to).to eq "2020-01-02"
    end

    it "on" do
      xml = <<~XML
        <date type="published"><on>2020-01-01</on></date>
      XML
      doc = described_class.from_xml xml
      expect(doc.type).to eq "published"
      expect(doc.on).to eq "2020-01-01"
    end
  end

  context "to XML" do
    it "from and to" do
      bdate = Relaton::Bib::Bdate.new
      bdate.type = "published"
      bdate.from = "2020-01-01"
      bdate.to = "2020-01-02"
      expect(described_class.to_xml(bdate)).to be_equivalent_to <<~XML
        <date type="published"><from>2020-01-01</from><to>2020-01-02</to></date>
      XML
    end

    it "on" do
      bdate = Relaton::Bib::Bdate.new
      bdate.type = "published"
      bdate.text = "str"
      bdate.on = "2020-01-01"
      expect(described_class.to_xml(bdate)).to be_equivalent_to <<~XML
        <date type="published" text="str"><on>2020-01-01</on></date>
      XML
    end
  end
end
