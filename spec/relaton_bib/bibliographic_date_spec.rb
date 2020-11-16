# forzen_string_literal: true

require "relaton_bib/bibliographic_item"

RSpec.describe RelatonBib::BibliographicDate do
  context "date on given" do
    subject do
      RelatonBib::BibliographicDate.new(type: "published", on: "November 2014")
    end

    it "parse 'November 2014' format date" do
      expect(subject.on).to eq "2014-11"
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

  context "dates from and to given" do
    subject do
      RelatonBib::BibliographicDate.new(
        type: "published", from: "2014-11", to: "2015-12"
      )
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
    item = RelatonBib::BibliographicDate.new type: "published", on: "2014-11-22"
    xml = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |builder|
      item.to_xml builder, date_format: :full
    end.doc.root.to_xml

    expect(xml).to be_equivalent_to <<~XML
      <date type="published"><on>2014-11-22</on></date>
    XML
  end

  it "handle year only" do
    item = RelatonBib::BibliographicDate.new(type: "published", on: "2014")
    xml = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |builder|
      item.to_xml builder, date_format: :full
    end.doc.root.to_xml

    expect(xml).to be_equivalent_to <<~XML
      <date type="published"><on>2014-01-01</on></date>
    XML
  end

  it "handle date not matched any patterns" do
    item = RelatonBib::BibliographicDate.new type: "published", on: ""
    item.instance_variable_set :@on, "Nov 2020"
    expect(item.on(:month)).to eq "Nov 2020"
  end
end
