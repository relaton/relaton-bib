RSpec.describe RelatonBib::XMLParser do
  it "creates item form xml" do
    xml = File.read "spec/examples/bib_item.xml", encoding: "UTF-8"
    item = RelatonBib::XMLParser.from_xml xml
    expect(item.to_xml).to be_equivalent_to xml
  end

  it "parse date from" do
    xml = <<~XML
      <bibitem id="id">
        <title type="main">Title</title>
        <date type="circulated"><from>2001-02-03</from></date>
      </bibitem>
    XML
    item = RelatonBib::XMLParser.from_xml xml
    expect(item.date.first.from.to_s).to eq "2001-02-03"
  end

  it "ignore empty dates" do
    xml = <<~XML
      <bibitem id="id">
        <title type="main">Title</title>
        <date type="circulated" />
      </bibitem>
    XML
    item = RelatonBib::XMLParser.from_xml xml
    expect(item.date).to be_empty 
  end

  it "warn if XML doesn't have bibitem or bibdata element" do
    item = ""
    expect { item = RelatonBib::XMLParser.from_xml "" }.to output(/can't find bibitem/)
      .to_stderr
    expect(item).to be_nil
  end
end
