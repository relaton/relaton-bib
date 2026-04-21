describe Relaton::Bib::Version do
  it "strips time and timezone from revision-date on XML round-trip" do
    xml_in = "<version><revision-date>2018-04-15T00:00:00Z</revision-date></version>"
    v = described_class.from_xml(xml_in)

    expect(v.revision_date).to be_a(::Date)
    expect(v.revision_date).not_to be_a(::DateTime)

    xml_out = v.to_xml
    expect(xml_out).to include "<revision-date>2018-04-15</revision-date>"
    expect(xml_out).not_to include "2018-04-15Z"
  end

  it "round-trips a plain date unchanged" do
    xml_in = "<version><revision-date>2018-04-15</revision-date></version>"
    expect(described_class.from_xml(xml_in).to_xml)
      .to include "<revision-date>2018-04-15</revision-date>"
  end
end
