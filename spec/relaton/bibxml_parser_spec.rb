describe Relaton::BibXMLParser do
  xit "parse RFC" do
    bibxml = File.read "spec/examples/rfc.xml", encoding: "UTF-8"
    bib = described_class.parse bibxml
    expect(bib.to_bibxml).to be_equivalent_to bibxml
  end

  xit "parse BCP" do
    bibxml = File.read "spec/examples/bcp_item.xml", encoding: "UTF-8"
    bib = described_class.parse bibxml
    expect(bib.to_bibxml).to be_equivalent_to bibxml
  end

  xit "IEEE" do
    bibxml = File.read "spec/examples/ieee_bibxml.xml", encoding: "UTF-8"
    bib = described_class.parse bibxml
    expect(bib.to_bibxml).to be_equivalent_to bibxml
  end

  xit "returns contacts" do
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
    cont = described_class.send(:contacts, addr)
    expect(cont[0]).to be_instance_of Relaton::Bib::Address
    expect(cont[1].type).to eq "phone"
    expect(cont[2].type).to eq "email"
    expect(cont[3].type).to eq "uri"
  end

  xit "parse I-D doctype" do
    doctype = described_class.doctype("I-D")
    expect(doctype).to be_instance_of Relaton::Bib::DocumentType
    expect(doctype.type).to eq "internet-draft"
  end

  context "parse PubID" do
    xit "Internet-Draft" do
      doc = Nokogiri::XML <<~END_XML
        <reference anchor="I-D.3k1n-6tisch-alice0">
        </reference>
      END_XML
      ref = doc.at "/reference"
      id = described_class.docids ref, nil
      expect(id).to be_a Array
      expect(id.first).to be_a Relaton::Bib::Docidentifier
      expect(id.first.type).to eq "Internet-Draft"
      expect(id.first.id).to eq "draft-3k1n-6tisch-alice0"
      expect(id[1]).to be_a Relaton::Bib::Docidentifier
      expect(id[1].type).to eq "I-D"
      expect(id[1].id).to eq "I-D.3k1n-6tisch-alice0"
      expect(id[1].scope).to eq "anchor"
    end

    xit "Internet-Draft from seriesInfo" do
      doc = Nokogiri::XML <<~END_XML
        <reference>
          <seriesInfo name="Internet-Draft" value="draft-3k1n-6tisch-alice0-01"/>
        </reference>
      END_XML
      ref = doc.at "/reference"
      id = described_class.docids ref, nil
      expect(id).to be_a Array
      expect(id.first).to be_a Relaton::Bib::Docidentifier
      expect(id.first.type).to eq "Internet-Draft"
      expect(id.first.id).to eq "draft-3k1n-6tisch-alice0-01"
    end

    xit "Internet-Draft from docName" do
      doc = Nokogiri::XML <<~END_XML
        <reference docName="draft-ietf-acvp-subsha-1.0">
        </reference>
      END_XML
      ref = doc.at "/reference"
      id = described_class.docids ref, nil
      expect(id[0]).to be_a Relaton::Bib::Docidentifier
      expect(id[0].type).to eq "Internet-Draft"
      expect(id[0].id).to eq "draft-ietf-acvp-subsha-1.0"
      expect(id[1].scope).to eq "docName"
    end

    xit "add version" do
      doc = Nokogiri::XML <<~END_XML
        <reference anchor="I-D.3k1n-6tisch-alice0-01">
        </reference>
      END_XML
      ref = doc.at "/reference"
      id = described_class.docids ref, "02"
      expect(id).to be_a Array
      expect(id.first).to be_a Relaton::Bib::Docidentifier
      expect(id.first.type).to eq "Internet-Draft"
      expect(id.first.id).to eq "draft-3k1n-6tisch-alice0-02"
    end
  end

  context "parse I-D format links" do
    xit "DOI" do
      doc = Nokogiri::XML <<~END_XML
        <reference anchor="I-D-12.3">
          <format type="DOC" target="https://www.rfc-editor.org/info/I-D-12.3.doc"/>
        </reference>
      END_XML
      ref = doc.at "/reference"
      link = described_class.link ref, nil, "1"
      expect(link.size).to eq 1
      expect(link[0][:type]).to eq "DOC"
    end

    xit "TXT" do
      bibxml = <<~END_XML
        <reference anchor="I-D-12.3">
          <format type="TXT" target="https://www.rfc-editor.org/info/rfc1.txt"/>
        </reference>
      END_XML
      id = described_class.parse bibxml
      expect(id.link).to be_instance_of Array
      expect(id.link[0]).to be_instance_of Relaton::Bib::Bsource
      expect(id.link[0].type).to eq "TXT"
      expect(id.link[0].content.to_s).to eq "https://www.rfc-editor.org/info/rfc1.txt"
    end
  end

  xit "parse RFC seriesinfo" do
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
    rfc = described_class.parse bibxml
    expect(rfc.docidentifier[2].type).to eq "DOI"
    expect(rfc.docidentifier[2].id).to eq "10.17487/RFC0001"
  end

  xit "parse incomplete month name" do
    expect(described_class.month("Sept")).to eq "09"
  end

  xit "skip empty organization" do
    bibxml = <<~END_XML
      <reference anchor="RFC0001" target="https://www.rfc-editor.org/info/rfc1">
        <front>
          <title>Host Software</title>
          <author>
            <organization>
            </organization>
          </author>
          <seriesInfo name="RFC" value="1"/>
        </front>
      </reference>
    END_XML
    rfc = described_class.parse bibxml
    expect(rfc.contributor).to be_empty
  end

  # it "parse organization as fullname" do
  #   bibxml = <<~END_XML
  #     <reference anchor="RFC0001" target="https://www.rfc-editor.org/info/rfc1">
  #       <front>
  #         <title>Host Software</title>
  #         <author fullname="IAB"/>
  #       </front>
  #     </reference>
  #   END_XML
  #   rfc = described_class.parse bibxml
  #   expect(rfc.contributor[0].entity).to be_instance_of Relaton::Bib::Organization
  #   expect(rfc.contributor[0].entity.name[0].content).to eq "IAB"
  #   expect(rfc.contributor[0].role[0].type).to eq "author"
  #   # expect(rfc.contributor[0].role[0].description[0].content).to eq "BibXML author"
  # end
end
