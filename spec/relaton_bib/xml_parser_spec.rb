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
    expect(item.relation.first.locality.first).to be_instance_of(
      RelatonBib::Locality,
    )
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
    expect(item.relation.first.source_locality.first).to be_instance_of(
      RelatonBib::SourceLocality,
    )
  end

  context "parse abstract" do
    it "with <br/> tag" do
      xml = <<~XML
        <bibitem id="id">
          <title type="main">Title</title>
          <abstract>Content<br/>Content</abstract>
        </bibitem>
      XML
      doc = Nokogiri::XML(xml).at "/bibitem"
      abstract = RelatonBib::XMLParser.send :fetch_abstract, doc
      expect(abstract[0].content).to eq "Content<br/>Content"
    end
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

  it "parse formatted address" do
    xml = <<~XML
      <bibitem id="id">
        <title type="main">Title</title>
        <contributor>
          <organization>
            <name>Organization</name>
            <address>
              <formattedAddress>Address</formattedAddress>
            </address>
          </organization>
        </contributor>
      </bibitem>
    XML
    item = RelatonBib::XMLParser.from_xml xml
    expect(item.contributor.first.entity.contact.first.formatted_address).to eq "Address"
  end

  it "warn if XML doesn't have bibitem or bibdata element" do
    item = ""
    expect { item = RelatonBib::XMLParser.from_xml "" }.to output(
      /Can't find bibitem/,
    ).to_stderr_from_any_process
    expect(item).to be_nil
  end

  describe ".fetch_doctype" do
    it "returns nil when ext is nil" do
      doctype = described_class.send(:fetch_doctype, nil)
      expect(doctype).to be_nil
    end

    it "returns nil when ext has no doctype element" do
      xml = "<ext></ext>"
      doc = Nokogiri::XML(xml)
      ext = doc.at("ext")
      doctype = described_class.send(:fetch_doctype, ext)
      expect(doctype).to be_nil
    end

    it "creates doctype from XML" do
      xml = <<~XML
        <ext>
          <doctype abbreviation="STD">Standard</doctype>
        </ext>
      XML
      doc = Nokogiri::XML(xml)
      ext = doc.at("ext")
      doctype = described_class.send(:fetch_doctype, ext)

      expect(doctype).to be_instance_of(RelatonBib::DocumentType)
      expect(doctype.type).to eq("Standard")
      expect(doctype.abbreviation).to eq("STD")
    end
  end

  describe ".fetch_editorialgroup" do
    it "returns nil when ext is nil" do
      group = described_class.send(:fetch_editorialgroup, nil)
      expect(group).to be_nil
    end

    it "returns nil when ext has no editorialgroup element" do
      xml = "<ext></ext>"
      doc = Nokogiri::XML(xml)
      ext = doc.at("ext")
      group = described_class.send(:fetch_editorialgroup, ext)
      expect(group).to be_nil
    end

    it "returns nil when editorialgroup has no technical-committee elements" do
      xml = <<~XML
        <ext>
          <editorialgroup></editorialgroup>
        </ext>
      XML
      doc = Nokogiri::XML(xml)
      ext = doc.at("ext")
      group = described_class.send(:fetch_editorialgroup, ext)
      expect(group).to be_nil
    end

    it "creates editorial group from XML" do
      xml = <<~XML
        <ext>
          <editorialgroup>
            <technical-committee type="TC" number="42" identifier="TC42" prefix="ISO/TC">Technical Committee 42</technical-committee>
          </editorialgroup>
        </ext>
      XML
      doc = Nokogiri::XML(xml)
      ext = doc.at("ext")
      group = described_class.send(:fetch_editorialgroup, ext)

      expect(group).to be_instance_of(RelatonBib::EditorialGroup)
      expect(group.technical_committee.first.workgroup.name).to eq("Technical Committee 42")
      expect(group.technical_committee.first.workgroup.type).to eq("TC")
      expect(group.technical_committee.first.workgroup.number).to eq(42)
      expect(group.technical_committee.first.workgroup.identifier).to eq("TC42")
      expect(group.technical_committee.first.workgroup.prefix).to eq("ISO/TC")
    end
  end

  describe ".fetch_ics" do
    it "returns empty array when ext is nil" do
      ics = described_class.send(:fetch_ics, nil)
      expect(ics).to eq([])
    end

    it "returns empty array when ext has no ics elements" do
      xml = "<ext></ext>"
      doc = Nokogiri::XML(xml)
      ext = doc.at("ext")
      ics = described_class.send(:fetch_ics, ext)
      expect(ics).to eq([])
    end

    it "creates ICS from XML" do
      xml = <<~XML
        <ext>
          <ics>
            <code>35.240.70</code>
            <text>IT applications in science</text>
          </ics>
        </ext>
      XML
      doc = Nokogiri::XML(xml)
      ext = doc.at("ext")
      ics = described_class.send(:fetch_ics, ext)

      expect(ics.first).to be_instance_of(RelatonBib::ICS)
      expect(ics.first.code).to eq("35.240.70")
      expect(ics.first.text).to eq("IT applications in science")
    end
  end

  describe ".fetch_structuredidentifier" do
    it "returns nil when ext is nil" do
      sid = described_class.send(:fetch_structuredidentifier, nil)
      expect(sid).to be_nil
    end

    it "returns empty collection when ext has no structuredidentifier elements" do
      xml = "<ext></ext>"
      doc = Nokogiri::XML(xml)
      ext = doc.at("ext")
      sid = described_class.send(:fetch_structuredidentifier, ext)
      expect(sid).to be_instance_of(RelatonBib::StructuredIdentifierCollection)
      expect(sid.any?).to be_falsey
    end

    it "creates structured identifier from XML" do
      xml = <<~XML
        <ext>
          <structuredidentifier type="ISO">
            <agency>ISO</agency>
            <class>Standard</class>
            <docnumber>19115</docnumber>
            <partnumber>1</partnumber>
            <edition>2</edition>
            <version>1.0</version>
            <supplementtype>Amendment</supplementtype>
            <supplementnumber>1</supplementnumber>
            <language>en</language>
            <year>2018</year>
          </structuredidentifier>
        </ext>
      XML
      doc = Nokogiri::XML(xml)
      ext = doc.at("ext")
      sid = described_class.send(:fetch_structuredidentifier, ext)

      expect(sid).to be_instance_of(RelatonBib::StructuredIdentifierCollection)
      expect(sid.any?).to be_truthy
      expect(sid[0].type).to eq("ISO")
      expect(sid[0].agency).to eq(["ISO"])
      expect(sid[0].klass).to eq("Standard")
      expect(sid[0].docnumber).to eq("19115")
      expect(sid[0].partnumber).to eq("1")
      expect(sid[0].edition).to eq("2")
      expect(sid[0].version).to eq("1.0")
      expect(sid[0].supplementtype).to eq("Amendment")
      expect(sid[0].supplementnumber).to eq("1")
      expect(sid[0].language).to eq("en")
      expect(sid[0].year).to eq("2018")
    end
  end
end
