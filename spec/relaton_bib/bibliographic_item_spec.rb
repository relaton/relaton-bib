# frozen_string_literal: true

require "yaml"
require "jing"

RSpec.describe "RelatonBib" => :BibliographicItem do
  context "instance" do
    subject do
      hash = YAML.load_file "spec/examples/bib_item.yml"
      RelatonBib::BibliographicItem.from_hash(hash)
    end

    it "is instance of BibliographicItem" do
      expect(subject).to be_instance_of RelatonBib::BibliographicItem
    end

    it "has array of titiles" do
      expect(subject.title).to be_instance_of(
        RelatonBib::TypedTitleStringCollection,
      )
      expect(subject.title(lang: "fr")[0].title.content).to eq(
        "Information g\u00E9ographique",
      )
    end

    it "has urls" do
      expect(subject.url).to eq "https://www.iso.org/standard/53798.html"
      expect(subject.url(:rss)).to eq "https://www.iso.org/contents/data/"\
                                      "standard/05/37/53798.detail.rss"
    end
    it "returns shortref" do
      expect(subject.shortref(subject.docidentifier.first)).to eq "ISOTC211:2014"
    end

    it "returns abstract with en language" do
      expect(subject.abstract(lang: "en")).to be_instance_of(
        RelatonBib::FormattedString,
      )
    end

    it "to most recent reference" do
      item = subject.to_most_recent_reference
      expect(item.relation[3].bibitem.structuredidentifier[0].year).to eq "2020"
      expect(item.structuredidentifier[0].year).to be_nil
    end

    it "to all parts" do
      item = subject.to_all_parts
      expect(item).to_not be subject
      expect(item.all_parts).to be true
      expect(item.relation.last.type).to eq "instance"
      expect(item.title.detect { |t| t.type == "title-part" }).to be_nil
      expect(item.title.detect { |t| t.type == "main" }.title.content).to eq(
        "Geographic information",
      )
      expect(item.abstract).to be_empty
      id_with_part = item.docidentifier.detect do |d|
        d.type != "Internet-Draft" && d.id =~ /-\d/
      end
      expect(id_with_part).to be_nil
      expect(item.docidentifier.reject { |d| d.id =~ %r{(all parts)} }.size)
        .to eq 1
      expect(item.docidentifier.detect { |d| d.id =~ /:[12]\d\d\d/ }).to be_nil
      expect(item.structuredidentifier.detect { |d| !d.partnumber.nil? })
        .to be_nil
      expect(item.structuredidentifier.detect { |d| d.docnumber =~ /-\d/ })
        .to be_nil
      expect(
        item.structuredidentifier.detect { |d| d.docnumber !~ %r{(all parts)} },
      ).to be_nil
      expect(
        item.structuredidentifier.detect { |d| d.docnumber =~ /:[12]\d\d\d/ },
      ).to be_nil
    end

    it "returns bibitem xml string" do
      file = "spec/examples/bib_item.xml"
      subject_xml = subject.to_xml
      File.write file, subject_xml, encoding: "utf-8" unless File.exist? file
      xml = File.read(file, encoding: "utf-8").gsub(
        /<fetched>\d{4}-\d{2}-\d{2}/, "<fetched>#{Date.today}"
      )
      expect(subject_xml).to be_equivalent_to xml
      schema = Jing.new "grammars/biblio.rng"
      errors = schema.validate file
      expect(errors).to eq []
    end

    it "returns bibdata xml string" do
      file = "spec/examples/bibdata_item.xml"
      subject_xml = subject.to_xml bibdata: true
      File.write file, subject_xml, encoding: "utf-8" unless File.exist? file
      xml = File.read(file, encoding: "utf-8").gsub(
        /<fetched>\d{4}-\d{2}-\d{2}/, "<fetched>#{Date.today}"
      )
      expect(subject_xml).to be_equivalent_to xml
      schema = Jing.new "spec/examples/isobib.rng"
      errors = schema.validate file
      expect(errors).to eq []
    end

    it "render only French laguage tagged string" do
      file = "spec/examples/bibdata_item_fr.xml"
      xml = subject.to_xml bibdata: true, lang: "fr"
      File.write file, xml, encoding: "UTF-8" unless File.exist? file
      expect(xml).to be_equivalent_to File.read(file, encoding: "UTF-8")
        .sub(/(?<=<fetched>)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
    end

    it "render addition elements" do
      xml = subject.to_xml { |b| b.element "test" }
      expect(xml).to include "<element>test</element>"
    end

    it "add note to xml" do
      xml = subject.to_xml note: [{ text: "Note", type: "note" }]
      expect(xml).to include "<note format=\"text/plain\" type=\"note\">"\
                             "Note</note>"
    end

    it "deals with hashes" do
      file = "spec/examples/bib_item.yml"
      h = RelatonBib::HashConverter.hash_to_bib(YAML.load_file(file))
      b = RelatonBib::BibliographicItem.new(**h)
      expect(b.to_xml).to be_equivalent_to subject.to_xml
    end

    it "converts item to hash" do
      hash = subject.to_hash
      file = "spec/examples/hash.yml"
      File.write file, hash.to_yaml unless File.exist? file
      h = YAML.load_file(file)
      h["fetched"] = Date.today.to_s
      expect(hash).to eq h
      expect(hash["revdate"]).to eq "2019-04-01"
    end

    context "converts to BibTex" do
      it "standard" do
        bibtex = subject.to_bibtex
        file = "spec/examples/misc.bib"
        File.write(file, bibtex, encoding: "utf-8") unless File.exist? file
        expect(bibtex).to eq File.read(file, encoding: "utf-8")
          .sub(/(?<=timestamp = {)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
      end

      it "techreport" do
        expect(subject).to receive(:type).and_return("techreport")
          .at_least :once
        bibtex = subject.to_bibtex
        file = "spec/examples/techreport.bib"
        File.write(file, bibtex, encoding: "utf-8") unless File.exist? file
        expect(bibtex).to eq File.read(file, encoding: "utf-8")
          .sub(/(?<=timestamp = {)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
      end

      it "manual" do
        expect(subject).to receive(:type).and_return("manual").at_least :once
        bibtex = subject.to_bibtex
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
          .sub(/(?<=timestamp = {)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
      end
    end

    it "convert item to AsciiBib" do
      file = "spec/examples/asciibib.adoc"
      bib = subject.to_asciibib
      File.write file, bib, encoding: "UTF-8" unless File.exist? file
      expect(bib).to eq File.read(file, encoding: "UTF-8").gsub(
        /(?<=fetched::\s)\d{4}-\d{2}-\d{2}/, Date.today.to_s
      )
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
        bcpbib = RelatonBib::BibliographicItem.from_hash(hash)
        file = "spec/examples/bcp_item.xml"
        bcpxml = bcpbib.to_bibxml
        File.write file, bcpxml, encoding: "UTF-8" unless File.exist? file
        expect(bcpxml).to be_equivalent_to File.read file, encoding: "UTF-8"
      end

      it "ID" do
        hash = YAML.load_file "spec/examples/id_item.yml"
        id = RelatonBib::BibliographicItem.from_hash hash
        file = "spec/examples/id_item.xml"
        idxml = id.to_bibxml
        File.write file, idxml, encoding: "UTF-8" unless File.exist? file
        expect(idxml).to be_equivalent_to File.read file, encoding: "UTF-8"
      end

      it "upcase anchor for IANA" do
        docid = RelatonBib::DocumentIdentifier.new id: "IANA dns-parameters", type: "IANA"
        ref_attrs = RelatonBib::BibliographicItem.new(docid: [docid]).send :ref_attrs
        expect(ref_attrs).to be_instance_of Hash
        expect(ref_attrs[:anchor]).to eq "DNS-PARAMETERS"
      end
    end

    it "convert item to citeproc" do
      file = "spec/examples/citeproc.json"
      cp = subject.to_citeproc
      File.write file, cp.to_json, encoding: "UTF-8" unless File.exist? file
      expect(cp).to eq JSON.parse(File.read(file, encoding: "UTF-8"))
    end
  end

  it "initialize with copyright object" do
    org = RelatonBib::Organization.new(
      name: "Test Org", abbreviation: "TO", url: "test.org",
    )
    owner = [RelatonBib::ContributionInfo.new(entity: org)]
    copyright = RelatonBib::CopyrightAssociation.new(owner: owner, from: "2018")
    bibitem = RelatonBib::BibliographicItem.new(
      formattedref: RelatonBib::FormattedRef.new(content: "ISO123"),
      copyright: [copyright],
    )
    expect(bibitem.to_xml).to include(
      "<formattedref format=\"text/plain\">ISO123</formattedref>",
    )
  end

  it "warn invalid type argument error" do
    expect { RelatonBib::BibliographicItem.new type: "type" }.to output(
      /\[relaton-bib\] document type "type" is invalid./,
    ).to_stderr
  end

  context RelatonBib::CopyrightAssociation do
    it "initialise with owner object" do
      org = RelatonBib::Organization.new(
        name: "Test Org", abbreviation: "TO", url: "test.org",
      )
      owner = [RelatonBib::ContributionInfo.new(entity: org)]
      copy = RelatonBib::CopyrightAssociation.new owner: owner, from: "2019"
      expect(copy.owner).to eq owner
    end
  end
end
