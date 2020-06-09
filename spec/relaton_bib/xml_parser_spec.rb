RSpec.describe RelatonBib::XMLParser do
  it "creates item from xml" do
    xml = File.read "spec/examples/bib_item.xml", encoding: "UTF-8"
    item = RelatonBib::XMLParser.from_xml xml
    expect(item.to_xml).to be_equivalent_to xml
  end

  it "creates item from bibdata xml" do
    xml = File.read "spec/examples/bibdata_item.xml", encoding: "UTF-8"
    item = RelatonBib::XMLParser.from_xml xml
    expect(item.to_xml(bibdata: true)).to be_equivalent_to xml
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

  it "parse locality not inclosed in localityStack" do
    xml = <<~XML
      <bibitem id="id">
        <title type="main">Title</title>
        <relation type="updates">
          <bibitem>
            <formattedref format="text/plain">ISO 19115</formattedref>
          </bibitem>
          <locality type="section">
            <referenceFrom>Reference from</referenceFrom>
          </locality>
        </relation>
      </bibitem>
    XML
    item = RelatonBib::XMLParser.from_xml xml
    expect(item.relation.first.locality.first).to be_instance_of RelatonBib::LocalityStack
  end

  it "parse sourceLocality not inclosed in sourceLocalityStack" do
    xml = <<~XML
      <bibitem id="id">
        <title type="main">Title</title>
        <relation type="updates">
          <bibitem>
            <formattedref format="text/plain">ISO 19115</formattedref>
          </bibitem>
          <sourceLocality type="section">
            <referenceFrom>Reference from</referenceFrom>
          </sourceLocality>
        </relation>
      </bibitem>
    XML
    item = RelatonBib::XMLParser.from_xml xml
    expect(item.relation.first.source_locality.first).to be_instance_of RelatonBib::SourceLocalityStack
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
