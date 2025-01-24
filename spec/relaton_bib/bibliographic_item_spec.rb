# frozen_string_literal: true

require "yaml"
require "jing"

RSpec.describe "RelatonBib" => :BibliographicItem do
  context "initialize" do
    xit "with keyword Hash" do
      keyword = [{ content: "keyword", language: "en", script: "Latn" }]
      bib = Relaton::Bib::Item.new(formattedref: "ref", keyword: keyword)
      expect(bib.keyword).to be_instance_of Array
      expect(bib.keyword.first).to be_instance_of Relaton::Bib::LocalizedString
      expect(bib.keyword.first.content).to eq "keyword"
      expect(bib.keyword.first.language).to eq ["en"]
      expect(bib.keyword.first.script).to eq ["Latn"]
    end
  end

  context "instance" do
    subject do
      hash = YAML.load_file "spec/examples/bib_item.yml"
      Relaton::Bib::Item.from_hash(hash)
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

    xit "has schema-version" do
      expect(subject.schema).to match(/^v\d+\.\d+\.\d+$/)
    end

    xit "is instance of BibliographicItem" do
      expect(subject).to be_instance_of RelatonBib::BibliographicItem
    end

    xit "get set fetched" do
      expect(subject.fetched).to eq "2022-05-02"
      subject.fetched = "2022-05-03"
      expect(subject.fetched).to eq "2022-05-03"
    end

    xit "has array of titiles" do
      expect(subject.title).to be_instance_of(
        RelatonBib::TypedTitleStringCollection,
      )
      expect(subject.title(lang: "fr")[0].title.content).to eq(
        "Information g\u00E9ographique",
      )
    end

    xit "has urls" do
      expect(subject.url).to eq "https://www.iso.org/standard/53798.html"
      expect(subject.url(:rss)).to eq "https://www.iso.org/contents/data/"\
                                      "standard/05/37/53798.detail.rss"
    end
    xit "returns shortref" do
      expect(subject.shortref(subject.docidentifier.first)).to eq "ISOTC211:2014"
    end

    xit "returns abstract with en language" do
      expect(subject.abstract(lang: "en")).to be_instance_of(
        RelatonBib::FormattedString,
      )
    end

    xit "to most recent reference" do
      item = subject.to_most_recent_reference
      expect(item.relation[3].bibitem.structuredidentifier[0].year).to eq "2020"
      expect(item.structuredidentifier[0].year).to be_nil
    end

    it "to all parts" do
      item = subject.to_all_parts
      expect(item).to_not be subject
      expect(item.all_parts).to be true
      expect(item.relation.last.type).to eq "instanceOf"
      expect(item.title.detect { |t| t.type == "title-part" }).to be_nil
      expect(item.title.detect { |t| t.type.nil? }.content).to eq(
        "Geographic information",
      )
      expect(item.abstract).to be_empty
      id_with_part = item.docidentifier.detect do |d|
        d.type != "Internet-Draft" && d.content =~ /-\d/
      end
      expect(id_with_part).to be_nil
      expect(item.docidentifier.count { |d| d.content !~ %r{(all parts)} })
        .to eq 1
      expect(item.docidentifier.detect { |d| d.content =~ /:[12]\d\d\d/ }).to be_nil
      expect(item.ext.structuredidentifier.detect { |d| !d.partnumber.nil? })
        .to be_nil
      expect(item.ext.structuredidentifier.detect { |d| d.docnumber =~ /-\d/ })
        .to be_nil
      expect(
        item.ext.structuredidentifier.detect { |d| d.docnumber !~ %r{(all parts)} },
      ).to be_nil
      expect(
        item.ext.structuredidentifier.detect { |d| d.docnumber =~ /:[12]\d\d\d/ },
      ).to be_nil
    end

    context "render XML" do
      it "returns bibitem xml string" do
        file = "spec/examples/from_old_yaml.xml"
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

      it "returns bibdata xml string" do
        file = "spec/examples/bibdata_from_old_yaml.xml"
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

      xit "render addition elements" do
        xml = subject.to_xml { |b| b.element "test" }
        expect(xml).to include "<element>test</element>"
      end

      xit "add note to xml" do
        xml = subject.to_xml note: [{ text: "Note", type: "note" }]
        expect(xml).to include "<note format=\"text/plain\" type=\"note\">" \
                               "Note</note>"
      end

      xit "render ext schema-verson" do
        # expect(subject).to receive(:respond_to?).with(:ext_schema).and_return(true).twice
        # expect(subject).to receive(:ext_schema).and_return("v1.0.0").twice
        expect(subject.to_xml(bibdata: true)).to include "<ext schema-version=\"v1.0.0\">"
      end
    end

    it "deals with hashes" do
      file = "spec/examples/bib_item.yml"
      h = Relaton::HashConverter.hash_to_bib(YAML.load_file(file))
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
        expect(hash["ext"]["schema-version"]).to eq "v1.0.0"
      end
    end

    context "converts to BibTex" do
      it "standard" do
        bibtex = subject.to_bibtex
          .sub(/(?<=timestamp = {)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
        file = "spec/examples/misc.bib"
        File.write(file, bibtex, encoding: "utf-8") unless File.exist? file
        expect(bibtex).to eq File.read(file, encoding: "utf-8")
          .sub(/(?<=timestamp = {)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
      end

      it "techreport" do
        expect(subject).to receive(:type).and_return("techreport")
          .at_least :once
        bibtex = subject.to_bibtex
          .sub(/(?<=timestamp = {)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
        file = "spec/examples/techreport.bib"
        File.write(file, bibtex, encoding: "utf-8") unless File.exist? file
        expect(bibtex).to eq File.read(file, encoding: "utf-8")
          .sub(/(?<=timestamp = {)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
      end

      it "manual" do
        expect(subject).to receive(:type).and_return("manual").at_least :once
        bibtex = subject.to_bibtex
          .sub(/(?<=timestamp = {)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
        file = "spec/examples/manual.bib"
        File.write(file, bibtex, encoding: "utf-8") unless File.exist? file
        expect(bibtex).to eq File.read(file, encoding: "utf-8")
          .sub(/(?<=timestamp = {)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
      end

      it "phdthesis" do
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
      it "RFC" do
        file = "spec/examples/rfc.xml"
        rfc = subject.to_bibxml
        File.write file, rfc, encoding: "UTF-8" unless File.exist? file
        expect(rfc).to be_equivalent_to File.read file, encoding: "UTF-8"
      end

      it "BCP" do
        hash = YAML.load_file "spec/examples/bcp_item.yml"
        bcpbib = Relaton::Bib::Item.from_hash(hash)
        file = "spec/examples/bcp_item.xml"
        bcpxml = bcpbib.to_bibxml
        File.write file, bcpxml, encoding: "UTF-8" unless File.exist? file
        expect(bcpxml).to be_equivalent_to File.read file, encoding: "UTF-8"
      end

      it "ID" do
        hash = YAML.load_file "spec/examples/id_item.yml"
        id = Relaton::Bib::Item.from_hash hash
        file = "spec/examples/id_item.xml"
        idxml = id.to_bibxml
        File.write file, idxml, encoding: "UTF-8" unless File.exist? file
        expect(idxml).to be_equivalent_to File.read file, encoding: "UTF-8"
      end

      it "render keywords" do
        docid = Relaton::Bib::Docidentifier.new type: "IETF", content: "ID"
        kw = Relaton::Bib::LocalizedString.new content: "kw"
        bibitem = Relaton::Bib::Item.new keyword: [kw], docidentifier: [docid]
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
        name = Relaton::Bib::TypedLocalizedString.new content: "org"
        entity = Relaton::Bib::Organization.new name: [name]
        desc = Relaton::Bib::LocalizedString.new content: "BibXML author"
        role = Relaton::Bib::Contributor::Role.new type: "author", description: [desc]
        contrib = Relaton::Bib::Contributor.new entity: entity, role: [role]
        bibitem = Relaton::Bib::Item.new docidentifier: [docid], contributor: [contrib]
        expect(bibitem.to_bibxml).to be_equivalent_to <<~XML
          <reference anchor="ID">
            <front>
              <author>
                <organization>org</organization>
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

  xit "initialize with copyright object" do
    org = Relaton::Bib::Organization.new(
      name: "Test Org", abbreviation: "TO", url: "test.org",
    )
    owner = [Relaton::Bib::Contributor.new(entity: org)]
    copyright = Relaton::Bib::Copyright.new(owner: owner, from: "2018")
    bibitem = Relaton::Bib::Item.new(
      formattedref: Relaton::Bib::Formattedref.new(content: "ISO123"),
      copyright: [copyright],
    )
    expect(bibitem.to_xml).to include(
      "<formattedref format=\"text/plain\">ISO123</formattedref>",
    )
  end

  xit "warn invalid type argument error" do
    expect { Relaton::Bib::Item.new type: "type" }.to output(
      /\[relaton-bib\] WARN: Type `type` is invalid./,
    ).to_stderr_from_any_process
  end

  context Relaton::Bib::Copyright do
    it "initialise with owner object" do
      org = Relaton::Bib::Organization.new(
        name: "Test Org", abbreviation: "TO", url: "test.org",
      )
      owner = [Relaton::Bib::Contributor.new(entity: org)]
      copy = Relaton::Bib::Copyright.new owner: owner, from: "2019"
      expect(copy.owner).to eq owner
    end
  end

  xit "initialize with string link" do
    bibitem = Relaton::Bib::Item.new link: ["http://example.com"]
    expect(bibitem.link[0]).to be_instance_of Relaton::Bib::Source
    expect(bibitem.link[0].content).to be_instance_of Addressable::URI
    expect(bibitem.link[0].content.to_s).to eq "http://example.com"
  end
end
