RSpec.describe "BibXML parser" do
  it do
    bibxml = File.read "spec/examples/rfc.xml", encoding: "UTF-8"
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
