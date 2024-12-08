# forzen_string_literal: true

describe Relaton::Bib::Date do
  context "date on given" do
    subject do
      described_class.new(type: "published", on: "November 2014")
    end

    it "parse 'November 2014' format date" do
      expect(subject.on).to eq "2014-11"
    end

    it "return full date if part isn't :year, :month, or :day" do
      expect(subject.on(:hour)).to eq "2014-11"
    end

    it "return Date" do
      expect(subject.on(:date)).to be_instance_of Date
    end

    it "returns xml string" do
      xml = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |builder|
        subject.to_xml builder
      end.doc.root.to_xml
      expect(xml).to be_equivalent_to <<~XML
        <date type="published"><on>2014-11</on></date>
      XML
    end

    it "returns xml string with full date" do
      xml = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |builder|
        subject.to_xml builder, date_format: :full
      end.doc.root.to_xml
      expect(xml).to be_equivalent_to <<~XML
        <date type="published"><on>2014-11-01</on></date>
      XML
    end
  end

  context "parse date" do
    subject { described_class.new(type: "published", on: "2014") }

    it "yyyy-mm-dd" do
      date = subject.send :parse_date, "2014-11-02"
      expect(date).to be_instance_of Date
      expect(date).to eq Date.new(2014, 11, 2)
    end

    it "yyyy-m-d" do
      expect(subject.send(:parse_date, "2014-2-3")).to eq Date.new(2014, 2, 3)
    end

    it "yyyy-mm" do
      expect(subject.send(:parse_date, "2014-11")).to eq Date.new(2014, 11, 1)
    end

    it "yyyy-m" do
      expect(subject.send(:parse_date, "2014-2")).to eq Date.new(2014, 2, 1)
    end

    it "yyyy" do
      expect(subject.send(:parse_date, "2014")).to eq Date.new(2014, 1, 1)
    end

    it "not match any pattern" do
      expect(subject.send(:parse_date, "November 2014")).to eq "November 2014"
    end
  end

  context "dates from and to given" do
    subject do
      described_class.new type: "published", from: "2014-11", to: "2015-12"
    end

    it "returns xml string" do
      xml = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |builder|
        subject.to_xml builder
      end.doc.root.to_xml
      expect(xml).to be_equivalent_to <<~XML
        <date type="published"><from>2014-11</from><to>2015-12</to></date>
      XML
    end

    it "returns xml string with short date" do
      xml = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |builder|
        subject.to_xml builder, date_format: :short
      end.doc.root.to_xml
      expect(xml).to be_equivalent_to <<~XML
        <date type="published"><from>2014-11</from><to>2015-12</to></date>
      XML
    end
  end

  it "handle full date" do
    item = described_class.new type: "published", on: "2014-11-22"
    xml = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |builder|
      item.to_xml builder, date_format: :full
    end.doc.root.to_xml

    expect(xml).to be_equivalent_to <<~XML
      <date type="published"><on>2014-11-22</on></date>
    XML
  end

  it "handle year only" do
    item = described_class.new(type: "published", on: "2014")
    xml = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |builder|
      item.to_xml builder, date_format: :full
    end.doc.root.to_xml

    expect(xml).to be_equivalent_to <<~XML
      <date type="published"><on>2014-01-01</on></date>
    XML
  end

  it "handle date not matched any patterns" do
    item = described_class.new type: "published", on: "Nov 2020"
    expect(item.on(:year)).to eq 2020
    expect(item.on(:month)).to eq 11
  end
end
