RSpec.describe "BibXML parser" do
  it "parse RFC" do
    bibxml = File.read "spec/examples/rfc.xml", encoding: "UTF-8"
    bib = RelatonBib::BibXMLParser.parse bibxml
    expect(bib.to_bibxml).to be_equivalent_to bibxml
  end

  it "parse BCP" do
    bibxml = File.read "spec/examples/bcp_item.xml", encoding: "UTF-8"
    bib = RelatonBib::BibXMLParser.parse bibxml
    expect(bib.to_bibxml).to be_equivalent_to bibxml
  end

  it "IEEE" do
    bibxml = File.read "spec/examples/ieee_bibxml.xml", encoding: "UTF-8"
    bib = RelatonBib::BibXMLParser.parse bibxml
    expect(bib.to_bibxml).to be_equivalent_to bibxml
  end

  it "returns contacts" do
    doc = Nokogiri::XML <<~END_XML
      <reference anchor="RFC8341" target="https://www.rfc-editor.org/info/rfc8341">
        <front>
          <title>Network Configuration Access Control Model</title>
          <author initials="A." surname="Bierman" fullname="A. Bierman">
            <address>
              <postal>
                <postalLine>123 av. 11-22</postalLine>
                <city>NY</city><code>123456</code>
                <country>USA</country>
                <region>Region</region>
              </postal>
              <phone>223322</phone>
              <email>somebody@somewhere.net</email>
              <uri>https://somewhere.net</uri>
            </address>
          </author>
        </front>
      </reference>
    END_XML
    addr = doc.at "//reference/front/author[1]/address"
    cont = RelatonBib::BibXMLParser.send(:contacts, addr)
    expect(cont[0]).to be_instance_of RelatonBib::Address
    expect(cont[1].type).to eq "phone"
    expect(cont[2].type).to eq "email"
    expect(cont[3].type).to eq "uri"
  end

  it "parse I-D doctype" do
    expect(RelatonBib::BibXMLParser.doctype("I-D")).to eq "internet-draft"
  end

  # it "return empty dates array when date parce fails" do
  #   doc = Nokogiri::XML <<~END_XML
  #     <reference>
  #       <front><date year="2001" month="14"/></front>
  #     </reference>
  #   END_XML
  #   ref = doc.at "/reference"
  #   expect(RelatonBib::BibXMLParser.dates(ref)).to eq []
  # end

  it "parse I-D format links" do
    doc = Nokogiri::XML <<~END_XML
      <reference anchor="I-D-12.3">
        <format type="DOC" target="https://www.rfc-editor.org/info/I-D-12.3.doc"/>
      </reference>
    END_XML
    ref = doc.at "/reference"
    link = RelatonBib::BibXMLParser.link ref, nil, "1"
    expect(link.size).to eq 1
    expect(link[0][:type]).to eq "DOC"
  end

  it "parse RFC seriesinfo" do
    bibxml = <<~END_XML
      <reference anchor="RFC0001" target="https://www.rfc-editor.org/info/rfc1">
        <front>
          <title>Host Software</title>
          <author initials="S." surname="Crocker" fullname="S. Crocker">
          <organization/>
          </author>
          <date year="1969" month="April"/>
        </front>
        <seriesInfo name="RFC" value="1"/>
        <seriesInfo name="DOI" value="10.17487/RFC0001"/>
      </reference>
    END_XML
    rfc = RelatonBib::BibXMLParser.parse bibxml
    expect(rfc.docidentifier[2].type).to eq "DOI"
    expect(rfc.docidentifier[2].id).to eq "10.17487/RFC0001"
  end

  # it "returns default affiliation" do
  #   doc = Nokogiri::XML <<~END_XML
  #     <reference>
  #       <front>
  #         <author fullname="Arthur son of Uther Pendragon" asciiFullname="Arthur son of Uther Pendragon">
  #           <organization abbrev="IETF">IETF</organization>
  #         </author>
  #       </front>
  #     </reference>
  #   END_XML
  #   ref = doc.at "/reference"
  #   contribs = RelatonBib::BibXMLParser.send(:contributors, ref)
  #   expect(contribs[0][:entity].affiliation[0]).to be_instance_of RelatonBib::Affiliation
  # end
end
