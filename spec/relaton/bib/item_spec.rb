# frozen_string_literal: true

require "jing"

describe Relaton::Bib::Item do
  before(:each) { Relaton::Bib.instance_variable_set :@configuration, nil }

  let(:fetched) { Date.parse("2022-05-02") }
  let(:local_attrs) { { language: "en", script: "Latn", locale: "EN-us" } }
  let(:title) do
    Relaton::Bib::Title.new type: "main", content: "Geographic information", **local_attrs
  end
  let(:title_col) { Relaton::Bib::TitleCollection.new << title }
  let(:source) do
    Relaton::Bib::Source.new type: "src", content: "https://www.iso.org/standard/53798.html", **local_attrs
  end
  let(:docid) { Relaton::Bib::Docidentifier.new type: "ISO", content: "ISO 211", scope: "part", primary: true }
  let(:date) { Relaton::Bib::Date.new type: "published", on: "2014-10" }
  let(:org_name) { Relaton::Bib::Organization::Name.new content: "ISO" }
  let(:org) { Relaton::Bib::Organization.new name: [org_name] }
  let(:role_dec) { Relaton::Bib::LocalizedString.new(content: "BibXML author", language: "en") }
  let(:role) { Relaton::Bib::Contributor::Role.new type: "author", description: [role_dec] }
  let(:contribution_info) { Relaton::Bib::ContributionInfo.new organization: org }
  let(:contrib) { Relaton::Bib::Contributor.new entity: org, role: [role] }
  let(:edition) { Relaton::Bib::Edition.new content: "ed 1", number: "1" }
  let(:version) { Relaton::Bib::Bversion.new revision_date: Date.parse("2020-11-22"), draft: "v1.0" }
  let(:note) { Relaton::Bib::Note.new content: "This is note." }
  let(:abstract) { Relaton::Bib::LocalizedString.new content: "This is abstract.", language: "en" }
  let(:stage) { Relaton::Bib::Status::Stage.new content: "published", abbreviation: "PUB" }
  let(:substage) { Relaton::Bib::Status::Stage.new content: "60", abbreviation: "6" }
  let(:status) { Relaton::Bib::Status.new stage: stage, substage: substage, iteration: "1" }
  let(:copyright) { Relaton::Bib::Copyright.new owner: [contribution_info], from: "2019", to: "2022", scope: "part" }
  let(:relation_docid) { Relaton::Bib::Docidentifier.new type: "ISO", content: "ISO 111" }
  let(:relation_bib) { Relaton::Bib::Item.new formattedref: "ISO 111", docidentifier: [relation_docid] }
  let(:relation) { Relaton::Bib::Relation.new(type: "instanceOf", bibitem: relation_bib) }
  let(:relation_col) { Relaton::Bib::RelationCollection.new << relation }
  let(:series) { Relaton::Bib::Series.new title: Relaton::Bib::TitleCollection.new, type: "main" }
  let(:medium) { Relaton::Bib::Medium.new size: "A4" }
  let(:place) { Relaton::Bib::Place.new city: "Geneva" }
  let(:price) { Relaton::Bib::Price.new currency: "USD", amount: 100 }
  let(:extent) { Relaton::Bib::Locality.new type: "section", reference_from: "1", reference_to: "2" }
  let(:size) { Relaton::Bib::Size.new value: [Relaton::Bib::Size::Value.new(type: "page", content: "10")] }
  let(:accesslocation) { "/path/to/file" }
  let(:license) { "license" }
  let(:classifications) { Relaton::Bib::Classification.new(type: "IEC", content: "123") }
  let(:taxon) { Relaton::Bib::LocalizedString.new content: "keyword", language: "en" }
  let(:keyword) { Relaton::Bib::Keyword.new taxon: [taxon] }
  let(:validity) { Relaton::Bib::Validity.new begins: "2020-01-01", ends: "2020-12-31", revision: "2020-06-01" }
  let(:image) { Relaton::Bib::Image.new id: "1", src: "http://example.com/image.jpg", mimetype: "image/jpeg" }
  let(:depiction) { Relaton::Bib::Depiction.new(scope: "scope", image: [image]) }
  let(:series) { Relaton::Bib::Series.new type: "main", title: sr_title_col }
  let(:bibxml) { File.read("spec/examples/bib_item.xml", encoding: "utf-8") }
  subject do
    # described_class.new(
    #   id: "ISO211", type: "standard", fetched: fetched, formattedref: "ISOTC211:2014", title: title_col,
    #   source: [source], docidentifier: [docid], docnumber: "211", date: [date], contributor: [contrib],
    #   edition: edition, version: [version], note: [note], language: ["en"], locale: ["EN-us"], script: ["Latn"],
    #   abstract: [abstract], status: status, copyright: [copyright], relation: relation_col, series: [series],
    #   medium: medium, place: [place], price: [price], extent: [extent], size: size, accesslocation: [accesslocation],
    #   license: [license], classification: [classifications], keyword: [keyword], validity: validity,
    #   depiction: depiction
    # )
    Relaton::Model::Bibitem.from_xml bibxml
  end

  context "initialize" do
    # it "with keyword Hash" do
    #   keyword = [{ content: "keyword", language: "en", script: "Latn" }]
    #   bib = Relaton::Bib::Item.new(formattedref: "ref", keyword: keyword)
    #   expect(bib.keyword).to be_instance_of Array
    #   expect(bib.keyword.first).to be_instance_of Relaton::Bib::LocalizedString
    #   expect(bib.keyword.first.content).to eq "keyword"
    #   expect(bib.keyword.first.language).to eq ["en"]
    #   expect(bib.keyword.first.script).to eq ["Latn"]
    # end

    it { is_expected.to be_instance_of Relaton::Bib::Item }
    it { expect(subject.id).to eq "ISOTC211" }
    it { expect(subject.type).to eq "standard" }
    it { expect(subject.schema_version).to match(/^v\d+\.\d+\.\d+$/) }
    it { expect(subject.fetched).to be_instance_of Date }
    it { expect(subject.formattedref).to eq "ISO TC 211" }
    it { expect(subject.docidentifier[0]).to be_instance_of Relaton::Bib::Docidentifier }
    it { expect(subject.docnumber).to eq "TC211" }
    it { expect(subject.title).to be_instance_of Relaton::Bib::TitleCollection }
    it { expect(subject.source[0]).to be_instance_of Relaton::Bib::Source }
    it { expect(subject.date[0]).to be_instance_of Relaton::Bib::Date }
    it { expect(subject.contributor[0]).to be_instance_of Relaton::Bib::Contributor }
    it { expect(subject.edition).to be_instance_of Relaton::Bib::Edition }
    it { expect(subject.version[0]).to be_instance_of Relaton::Bib::Bversion }
    it { expect(subject.note[0]).to be_instance_of Relaton::Bib::Note }
    it { expect(subject.language).to eq ["en", "fr"] }
    it { expect(subject.locale).to eq ["en-US"] }
    it { expect(subject.script).to eq ["Latn"] }
    it { expect(subject.abstract[0]).to be_instance_of Relaton::Bib::LocalizedString }
    it { expect(subject.status).to be_instance_of Relaton::Bib::Status }
    it { expect(subject.copyright[0]).to be_instance_of Relaton::Bib::Copyright }
    it { expect(subject.relation).to be_instance_of Relaton::Bib::RelationCollection }
    it { expect(subject.series[0]).to be_instance_of Relaton::Bib::Series }
    it { expect(subject.medium).to be_instance_of Relaton::Bib::Medium }
    it { expect(subject.place[0]).to be_instance_of Relaton::Bib::Place }
    it { expect(subject.price[0]).to be_instance_of Relaton::Bib::Price }
    it { expect(subject.extent[0]).to be_instance_of Relaton::Bib::Extent }
    it { expect(subject.size).to be_instance_of Relaton::Bib::Size }
    it { expect(subject.accesslocation).to eq %w[accesslocation1 accesslocation2] }
    it { expect(subject.license).to eq %w[License] }
    it { expect(subject.classification[0]).to be_instance_of Relaton::Bib::Classification }
    it { expect(subject.keyword[0]).to be_instance_of Relaton::Bib::Keyword }
    it { expect(subject.validity).to be_instance_of Relaton::Bib::Validity }
    it { expect(subject.depiction).to be_instance_of Relaton::Bib::Depiction }
  end

  context "instance" do
    context "to_xml" do
      it "bibitem" do
        xml = Relaton::Model::Bibitem.to_xml(subject)
        expect(xml).to be_equivalent_to bibxml
        <<~XML
          <bibitem type="standard" schema-version="v1.4.1" id="ISO211">
            <fetched>2022-05-02</fetched>
            <formattedref>ISOTC211:2014</formattedref>
            <title language="en" locale="EN-us" script="Latn" type="main">Geographic information</title>
            <uri language="en" locale="EN-us" script="Latn" type="src">https://www.iso.org/standard/53798.html</uri>
            <docidentifier type="ISO" scope="part" primary="true">ISO 211</docidentifier>
            <docnumber>211</docnumber>
            <date type="published">
              <on>2014-10</on>
            </date>
            <contributor>
              <role type="author">
                <description language="en">BibXML author</description>
              </role>
              <organization>
                <name>ISO</name>
              </organization>
            </contributor>
            <edition number="1">ed 1</edition>
            <version>
              <revision-date>2020-11-22</revision-date>
              <draft>v1.0</draft>
            </version>
            <note>This is note.</note>
            <language>en</language>
            <locale>EN-us</locale>
            <script>Latn</script>
            <abstract language="en">This is abstract.</abstract>
            <status>
              <stage abbreviation="PUB">published</stage>
              <substage abbreviation="6">60</substage>
              <iteration>1</iteration>
            </status>
            <copyright>
              <from>2019</from>
              <to>2022</to>
              <owner>
                <organization>
                  <name>ISO</name>
                </organization>
              </owner>
              <scope>part</scope>
            </copyright>
            <relation type="instanceOf">
              <bibitem>
                <docidentifier type="ISO">ISO 111</docidentifier>
                <formattedref>ISO 111</formattedref>
              </bibitem>
            </relation>
          </bibitem>
        XML
      end
    end

    context "makeid" do
      xit "with docid" do
        expect(subject.makeid(nil, false)).to eq "ISOTC211"
      end

      xit "with argument" do
        docid = Relaton::Bib::Docidentifier.new type: "ISO", id: "ISO 123 (E)"
        expect(subject.makeid(docid, false)).to eq "ISO123E"
      end
    end

    it "has schema-version" do
      expect(subject.schema_version).to match(/^v\d+\.\d+\.\d+$/)
    end

    it "get set fetched" do
      expect(subject.fetched).to eq Date.parse("2024-12-11")
      subject.fetched = Date.parse "2022-05-03"
      expect(subject.fetched).to eq Date.parse "2022-05-03"
    end

    # it "has array of titiles" do
    #   expect(subject.title).to be_instance_of Relaton::Bib::TitleCollection
    # end

    # it "has urls" do
    #   expect(subject.url).to be_instance_of Array
    #   expect(subject.url.first).to be_instance_of Relaton::Bib::Bsource
    # end

    it "returns shortref" do
      expect(subject.shortref(subject.docidentifier.first)).to eq "ISOTC211:2014"
    end

    it "returns abstract with en language" do
      expect(subject.abstract(lang: "en")).to be_instance_of Relaton::Bib::LocalizedString
    end

    xit "to most recent reference" do
      item = subject.to_most_recent_reference
      expect(item.relation[3].bibitem.structuredidentifier[0].year).to eq "2020"
      expect(item.structuredidentifier[0].year).to be_nil
    end

    xit "to all parts" do
      item = subject.to_all_parts
      expect(item).to_not be subject
      expect(item.all_parts).to be true
      expect(item.relation.last.type).to eq "instanceOf"
      expect(item.title.detect { |t| t.type == "title-part" }).to be_nil
      expect(item.title.detect { |t| t.type == "main" }.title.content).to eq(
        "Geographic information",
      )
      expect(item.abstract).to be_empty
      id_with_part = item.docidentifier.detect do |d|
        d.type != "Internet-Draft" && d.id =~ /-\d/
      end
      expect(id_with_part).to be_nil
      expect(item.docidentifier.count { |d| d.id =~ %r{(all parts)} }).to eq 1
      expect(item.docidentifier.detect { |d| d.id =~ /:[12]\d\d\d/ }).to be_nil
      expect(item.structuredidentifier.detect { |d| !d.partnumber.nil? }).to be_nil
      expect(item.structuredidentifier.detect { |d| d.docnumber =~ /-\d/ }).to be_nil
      expect(item.structuredidentifier.detect { |d| d.docnumber !~ %r{(all parts)} }).to be_nil
      expect(item.structuredidentifier.detect { |d| d.docnumber =~ /:[12]\d\d\d/ }).to be_nil
    end

    context "render XML" do
      xit "returns bibitem xml string" do
        file = "spec/examples/bib_item.xml"
        subject_xml = subject.to_xml
          .gsub(/(?<=<fetched>)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
        File.write file, subject_xml, encoding: "utf-8" unless File.exist? file
        xml = File.read(file, encoding: "utf-8")
          .gsub(/(?<=<fetched>)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
        expect(subject_xml).to be_equivalent_to xml
        schema = Jing.new "grammars/biblio-compile.rng"
        errors = schema.validate file
        expect(errors).to eq []
      end

      xit "returns bibdata xml string" do
        file = "spec/examples/bibdata_item.xml"
        subject_xml = subject.to_xml(bibdata: true)
          .gsub(/(?<=<fetched>)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
        File.write file, subject_xml, encoding: "utf-8" unless File.exist? file
        xml = File.read(file, encoding: "utf-8")
          .gsub(/(?<=<fetched>)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
        expect(subject_xml).to be_equivalent_to xml
        schema = Jing.new "grammars/biblio-compile.rng"
        errors = schema.validate file
        expect(errors).to eq []
      end

      xit "render only French laguage tagged string" do
        file = "spec/examples/bibdata_item_fr.xml"
        xml = subject.to_xml(bibdata: true, lang: "fr")
          .sub(/(?<=<fetched>)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
        File.write file, xml, encoding: "UTF-8" unless File.exist? file
        expect(xml).to be_equivalent_to File.read(file, encoding: "UTF-8")
          .sub(/(?<=<fetched>)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
      end

      # it "render addition elements" do
      #   xml = subject.to_xml { |b| b.element "test" }
      #   expect(xml).to include "<element>test</element>"
      # end

      xit "add note to xml" do
        xml = subject.to_xml note: [{ text: "Note", type: "note" }]
        expect(xml).to include "<note format=\"text/plain\" type=\"note\">Note</note>"
      end

      xit "render ext schema-verson" do
        expect(subject).to receive(:respond_to?).with(:ext_schema).and_return(true).twice
        expect(subject).to receive(:ext_schema).and_return("v1.0.0").twice
        expect(Relaton::Model::Bibitem.to_xml(subject)).to include "<ext schema-version=\"v1.0.0\">"
      end
    end

    xit "deals with hashes" do
      file = "spec/examples/bib_item.yml"
      h = Relaton::Bib::HashConverter.hash_to_bib(YAML.load_file(file))
      b = Relaton::Bib::Item.new(**h)
      expect(b.to_xml).to be_equivalent_to subject.to_xml
    end

    context "converts item to hash" do
      xit do
        hash = subject.to_hash
        file = "spec/examples/hash.yml"
        File.write file, hash.to_yaml unless File.exist? file
        expect(hash).to eq YAML.load_file(file)
        expect(hash["revdate"]).to eq "2019-04-01"
      end

      xit "with ext schema-version" do
        expect(subject).to receive(:respond_to?).with(:ext_schema).and_return(true).twice
        expect(subject).to receive(:ext_schema).and_return("v1.0.0").twice
        hash = subject.to_hash
        expect(hash["ext"]).to eq "schema-version" => "v1.0.0"
      end
    end

    context "converts to BibTex" do
      xit "standard" do
        bibtex = subject.to_bibtex
          .sub(/(?<=timestamp = {)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
        file = "spec/examples/misc.bib"
        File.write(file, bibtex, encoding: "utf-8") unless File.exist? file
        expect(bibtex).to eq File.read(file, encoding: "utf-8")
          .sub(/(?<=timestamp = {)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
      end

      xit "techreport" do
        expect(subject).to receive(:type).and_return("techreport")
          .at_least :once
        bibtex = subject.to_bibtex
          .sub(/(?<=timestamp = {)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
        file = "spec/examples/techreport.bib"
        File.write(file, bibtex, encoding: "utf-8") unless File.exist? file
        expect(bibtex).to eq File.read(file, encoding: "utf-8")
          .sub(/(?<=timestamp = {)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
      end

      xit "manual" do
        expect(subject).to receive(:type).and_return("manual").at_least :once
        bibtex = subject.to_bibtex
          .sub(/(?<=timestamp = {)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
        file = "spec/examples/manual.bib"
        File.write(file, bibtex, encoding: "utf-8") unless File.exist? file
        expect(bibtex).to eq File.read(file, encoding: "utf-8")
          .sub(/(?<=timestamp = {)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
      end

      xit "phdthesis" do
        expect(subject).to receive(:type).and_return("phdthesis").at_least :once
        bibtex = subject.to_bibtex
        file = "spec/examples/phdthesis.bib"
        File.write(file, bibtex, encoding: "utf-8") unless File.exist? file
        expect(bibtex).to eq File.read(file, encoding: "utf-8")
      end
    end

    xit "convert item to AsciiBib" do
      file = "spec/examples/asciibib.adoc"
      bib = subject.to_asciibib
      File.write file, bib, encoding: "UTF-8" unless File.exist? file
      expect(bib).to eq File.read(file, encoding: "UTF-8")
    end

    context "convert item to BibXML" do
      xit "RFC" do
        file = "spec/examples/rfc.xml"
        rfc = subject.to_bibxml
        File.write file, rfc, encoding: "UTF-8" unless File.exist? file
        expect(rfc).to be_equivalent_to File.read file, encoding: "UTF-8"
      end

      xit "BCP" do
        hash = YAML.load_file "spec/examples/bcp_item.yml"
        bcpbib = Relaton::Bib::Item.from_hash(hash)
        file = "spec/examples/bcp_item.xml"
        bcpxml = bcpbib.to_bibxml
        File.write file, bcpxml, encoding: "UTF-8" unless File.exist? file
        expect(bcpxml).to be_equivalent_to File.read file, encoding: "UTF-8"
      end

      xit "ID" do
        hash = YAML.load_file "spec/examples/id_item.yml"
        id = Relaton::Bib::Item.from_hash hash
        file = "spec/examples/id_item.xml"
        idxml = id.to_bibxml
        File.write file, idxml, encoding: "UTF-8" unless File.exist? file
        expect(idxml).to be_equivalent_to File.read file, encoding: "UTF-8"
      end

      xit "render keywords" do
        docid = Relaton::Bib::Docidentifier.new type: "IETF", content: "ID"
        taxon = Relaton::Bib::LocalizedString.new content: "keyword", language: "en"
        bibitem = Relaton::Bib::Item.new taxon: [taxon], docidentifier: [docid]
        expect(bibitem.to_bibxml(include_keywords: true)).to be_equivalent_to <<~XML
          <reference anchor="ID">
            <front>
              <keyword>kw</keyword>
            </front>
          </reference>
        XML
      end

      it "render person's forename" do
        docid = Relaton::Bib::Docidentifier.new type: "IETF", content: "ID"
        sname = Relaton::Bib::LocalizedString.new content: "Cook"
        fname = Relaton::Bib::Forename.new content: "James", initial: "J"
        name = Relaton::Bib::FullName.new surname: sname, forename: [fname]
        entity = Relaton::Bib::Person.new name: name
        contrib = Relaton::Bib::Contributor.new entity: entity
        bibitem = Relaton::Bib::Item.new docidentifier: [docid], contributor: [contrib]
        expect(bibitem.to_bibxml).to be_equivalent_to <<~XML
          <reference anchor="ID">
            <front>
              <author fullname="James Cook" initials="J." surname="Cook">
                <organization/>
              </author>
            </front>
          </reference>
        XML
      end

      it "render organization as author name" do
        docid = Relaton::Bib::Docidentifier.new type: "IETF", content: "ID"
        name = Relaton::Bib::TypedLocalizedString.new content: "Org Name"
        entity = Relaton::Bib::Organization.new name: [name]
        desc = Relaton::Bib::LocalizedString.new content: "BibXML author", language: "en"
        role = [Relaton::Bib::Contributor::Role.new(type: "author", description: [desc])]
        contrib = Relaton::Bib::Contributor.new entity: entity, role: role
        bibitem = Relaton::Bib::Item.new docidentifier: [docid], contributor: [contrib]
        expect(bibitem.to_bibxml).to be_equivalent_to <<~XML
          <reference anchor="ID">
            <front>
              <author>
                <organization>Org Name</organization>
              </author>
            </front>
          </reference>
        XML
      end
    end

    xit "convert item to citeproc" do
      file = "spec/examples/citeproc.json"
      cp = subject.to_citeproc
      File.write file, cp.to_json, encoding: "UTF-8" unless File.exist? file
      json = JSON.parse(File.read(file, encoding: "UTF-8"))
      json[0]["timestamp"] = Date.today.to_s
      cp[0]["timestamp"] = Date.today.to_s
      expect(cp).to eq json
    end
  end

  it "initialize with copyright object" do
    orgname = Relaton::Bib::TypedLocalizedString.new content: "Test Org"
    abbreviation = Relaton::Bib::LocalizedString.new content: "TO", language: "en"
    org = Relaton::Bib::Organization.new(name: [orgname], abbreviation: abbreviation, url: "test.org")
    contribution_info = Relaton::Bib::ContributionInfo.new organization: org
    copyright = Relaton::Bib::Copyright.new(owner: [contribution_info], from: "2018")
    bibitem = Relaton::Bib::Item.new(formattedref: "ISO123", copyright: [copyright])
    expect(Relaton::Model::Bibitem.to_xml(bibitem)).to include(
      "<formattedref>ISO123</formattedref>",
    )
  end

  xit "warn invalid type argument error" do
    expect { Relaton::Bib::Item.new type: "type" }.to output(
      /\[relaton-bib\] WARNING: type `type` is invalid./,
    ).to_stderr_from_any_process
  end

  context Relaton::Bib::Copyright do
    it "initialise with owner object" do
      org = Relaton::Bib::Organization.new(
        name: "Test Org", abbreviation: "TO", url: "test.org",
      )
      copy = Relaton::Bib::Copyright.new owner: [org], from: "2019"
      expect(copy.owner.first).to eq org
    end
  end

  xit "initialize with string link" do
    bibitem = Relaton::Bib::Item.new source: ["http://example.com"]
    expect(bibitem.source[0]).to be_instance_of Relaton::Bib::Bsource
    expect(bibitem.source[0].content).to be_instance_of Addressable::URI
    expect(bibitem.source[0].content.to_s).to eq "http://example.com"
  end
end
