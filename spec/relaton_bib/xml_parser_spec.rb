RSpec.describe RelatonBib::XMLParser do
  it "creates item form xml" do
    xml = File.read "spec/examples/bib_item.xml", encoding: "UTF-8"
    item = RelatonBib::XMLParser.from_xml xml
    expect(item.to_xml).to be_equivalent_to xml 
  end
end