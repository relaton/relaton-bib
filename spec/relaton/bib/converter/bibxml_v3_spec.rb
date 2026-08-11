describe Relaton::Bib::Converter::BibXml, "strict RFC XML v3 mode" do
  def item_from(yaml)
    Relaton::Bib::Item.from_yaml yaml
  end

  def v3_xml(item, **opts)
    described_class.from_item(item, v3: true, **opts).to_xml
  end

  context "IETF home standard" do
    let(:item) { Relaton::Bib::Item.from_yaml File.read("spec/fixtures/rfc_v3.yml") }
    subject { v3_xml(item) }

    it "matches the expected RFC XML v3 reference" do
      expect(subject).to be_equivalent_to File.read("spec/fixtures/rfc_v3.xml", encoding: "UTF-8")
    end

    it "renders authoritative identifiers as seriesInfo, not refcontent" do
      expect(subject).to include '<seriesInfo name="RFC" value="2119"/>'
      expect(subject).to include '<seriesInfo name="BCP" value="14"/>'
      expect(subject).not_to include "<refcontent>"
    end

    it "emits the stream element" do
      expect(subject).to include "<stream>IETF</stream>"
    end

    it "never emits the deprecated format element" do
      expect(subject).not_to include "<format"
    end
  end

  context "non-IETF publisher" do
    let(:item) { Relaton::Bib::Item.from_yaml File.read("spec/fixtures/iso_v3.yml") }
    subject { v3_xml(item) }

    it "matches the expected RFC XML v3 reference" do
      expect(subject).to be_equivalent_to File.read("spec/fixtures/iso_v3.xml", encoding: "UTF-8")
    end

    it "renders authoritative identifiers as refcontent, not seriesInfo" do
      expect(subject).to include "<refcontent>ISO 20483:2013-2014</refcontent>"
      expect(subject).not_to include "<seriesInfo"
    end

    it "ascii-folds accented author names" do
      author = Nokogiri::XML(subject).at("//author[@surname='Nürk']")
      expect(author["asciiSurname"]).to eq "Nurk"
      expect(author["initials"]).to eq "Ö."
      expect(author["asciiInitials"]).to eq "O."
    end

    it "transliterates letters NFKD cannot decompose" do
      yaml = <<~YAML
        id: T
        docnumber: T
        title:
          - content: T
        contributor:
          - person:
              name:
                surname:
                  content: Sørensen
                formatted_initials:
                  content: Æ.
        ext:
      YAML
      author = Nokogiri::XML(v3_xml(item_from(yaml))).at("//author")
      expect(author["asciiSurname"]).to eq "Sorensen"
      expect(author["asciiInitials"]).to eq "AE."
    end

    it "ascii-folds organization names" do
      expect(subject)
        .to include 'ascii="International Organization for Standardization"'
    end
  end

  describe "refcontent from series" do
    let(:yaml) do
      <<~YAML
        id: J1
        docnumber: J1
        title:
          - content: An article
        series:
          - title:
              - content: Journal of Things
            organization: Thing Press
            run: "3"
        ext:
      YAML
    end
    subject { v3_xml(item_from(yaml)) }

    it "uses refcontent for a series with no number" do
      expect(subject).to include "<refcontent>"
      expect(subject).to include "Journal of Things"
    end

    it "does not emit a valueless seriesInfo" do
      expect(subject).not_to match(/<seriesInfo name="Journal of Things"\s*\/>/)
    end
  end

  describe "series with a number" do
    let(:yaml) do
      <<~YAML
        id: J2
        docnumber: J2
        title:
          - content: An article
        series:
          - title:
              - content: Journal of Things
            number: "7"
        ext:
      YAML
    end

    it "uses seriesInfo when both title and number are present" do
      expect(v3_xml(item_from(yaml)))
        .to include '<seriesInfo name="Journal of Things" value="7"/>'
    end
  end

  describe "series not duplicated by an identifier" do
    let(:yaml) do
      <<~YAML
        id: D1
        docnumber: D1
        title:
          - content: A draft
        docidentifier:
          - content: RFC 1
            type: IETF
            primary: true
        contributor:
          - organization:
              name:
                - content: Internet Engineering Task Force
              abbreviation:
                content: IETF
        series:
          - number: draft-ietf-somewg-someprotocol-07
            title:
              - content: Internet-Draft
          - number: "1"
            title:
              - content: RFC
        ext:
      YAML
    end
    subject { v3_xml(item_from(yaml)) }

    it "keeps a series whose name no identifier supplies" do
      expect(subject).to include(
        '<seriesInfo name="Internet-Draft" value="draft-ietf-somewg-someprotocol-07"/>',
      )
    end

    it "drops a series the identifiers already render" do
      expect(subject.scan('name="RFC"').size).to eq 1
    end
  end

  describe "stream values" do
    def stream_item(name)
      item_from("id: R\ndocnumber: R\ntitle:\n  - content: T\n" \
                "series:\n  - type: stream\n    title:\n" \
                "      - content: #{name}\next:\n")
    end

    it "normalises the RFC Editor's spelling of the independent stream" do
      expect(v3_xml(stream_item("Independent Submission")))
        .to include "<stream>independent</stream>"
    end

    it "accepts the editorial stream added by RFC 9280" do
      expect(v3_xml(stream_item("Editorial")))
        .to include "<stream>editorial</stream>"
    end

    it "drops a value the v3 grammar does not allow" do
      expect(v3_xml(stream_item("Legacy"))).not_to include "<stream>"
    end

    # A stream series has no number, so it must never become a <seriesInfo>.
    it "never renders the stream series as seriesInfo in either mode" do
      item = stream_item("IETF")
      expect(v3_xml(item)).not_to include "<seriesInfo"
      expect(item.to_rfcxml).not_to include "<seriesInfo"
    end
  end

  describe "referencegroup dispatch" do
    let(:yaml) do
      <<~YAML
        id: STD68
        docnumber: STD68
        title:
          - content: A collection
        docidentifier:
          - content: STD 68
            type: IETF
            primary: true
        relation:
          - type: includes
            bibitem:
              docnumber: RFC5234
              title:
                - content: Included RFC5234
        ext:
      YAML
    end
    subject { v3_xml(item_from(yaml)) }

    it "builds a referencegroup for any includes relation, not only BCP" do
      expect(subject).to start_with "<referencegroup"
      expect(subject).to include "Included RFC5234"
    end

    it "gives every member reference an anchor" do
      Nokogiri::XML(subject).xpath("//reference").each do |ref|
        expect(ref["anchor"]).not_to be_nil
        expect(ref["anchor"]).not_to be_empty
      end
    end

    it "gives the referencegroup an anchor even with no docidentifier" do
      yaml = <<~YAML
        id: G1
        docnumber: G1
        relation:
          - type: includes
            bibitem:
              docnumber: RFC1
              title:
                - content: Included
        ext:
      YAML
      expect(Nokogiri::XML(v3_xml(item_from(yaml))).root["anchor"]).to eq "G1"
    end

    it "still uses a plain reference when there is no includes relation" do
      expect(v3_xml(item_from("id: X\ndocnumber: X\ntitle:\n  - content: T\next:\n")))
        .to start_with "<reference"
    end
  end

  describe "schema-required fallbacks" do
    it "inserts a placeholder author when the item has no contributors" do
      xml = v3_xml(item_from("id: X\ndocnumber: X\ntitle:\n  - content: T\next:\n"))
      expect(xml).to include '<author surname="Unknown"/>'
    end

    it "does not insert a placeholder author when contributors exist" do
      expect(v3_xml(Relaton::Bib::Item.from_yaml(File.read("spec/fixtures/iso_v3.yml"))))
        .not_to include 'surname="Unknown"'
    end

    it "never leaves whitespace in an anchor" do
      yaml = <<~YAML
        id: ISO1
        title:
          - content: T
        docidentifier:
          - content: ISO 1:2020
            type: ISO
            primary: true
        ext:
      YAML
      expect(Nokogiri::XML(v3_xml(item_from(yaml))).root["anchor"])
        .not_to match(/\s/)
    end

    it "falls back to the item id when no anchor can be derived" do
      expect(v3_xml(item_from("id: Y\next:\n")))
        .to include '<reference anchor="Y"'
    end

    it "falls back to formattedref as the title when there is no title" do
      yaml = "id: X\ndocnumber: X\nformattedref:\n  content: ISO 123:1994\next:\n"
      expect(v3_xml(item_from(yaml)))
        .to include "<title>ISO 123:1994</title>"
    end
  end

  describe "anchor option" do
    let(:item) { Relaton::Bib::Item.from_yaml File.read("spec/fixtures/iso_v3.yml") }

    it "overrides the derived anchor" do
      expect(v3_xml(item, anchor: "ISO712")).to include '<reference anchor="ISO712"'
    end

    it "derives the anchor from docnumber when not given" do
      expect(v3_xml(item)).to include '<reference anchor="ISO20483"'
    end
  end

  describe "ItemData#to_rfcxml" do
    let(:item) { Relaton::Bib::Item.from_yaml File.read("spec/fixtures/iso_v3.yml") }

    it "forwards the v3 option" do
      expect(item.to_rfcxml(v3: true)).to include "<refcontent>"
    end

    it "defaults to the BibXML shape" do
      expect(item.to_rfcxml).not_to include "<refcontent>"
    end

    it "forwards include_keywords" do
      rfc = Relaton::Bib::Item.from_yaml File.read("spec/fixtures/rfc_v3.yml")
      expect(rfc.to_rfcxml(v3: true, include_keywords: false)).not_to include "<keyword>"
      expect(rfc.to_rfcxml(v3: true)).to include "<keyword>Standards</keyword>"
    end
  end

  # The canonical xml2rfc v3 RNG only has a `start` rule for <rfc>, so a bare
  # <reference> cannot be handed to Jing without editing a third-party schema.
  # These assert the parts of that grammar a <reference> has to satisfy.
  describe "RFC 7991 grammar conformance" do
    %w[rfc_v3 iso_v3].each do |fixture|
      context fixture do
        let(:doc) do
          item = Relaton::Bib::Item.from_yaml File.read("spec/fixtures/#{fixture}.yml")
          Nokogiri::XML(v3_xml(item))
        end

        it "gives <reference> the mandatory anchor" do
          expect(doc.root["anchor"]).not_to be_nil
        end

        it "orders <reference> children as stream?, front, then the rest" do
          names = doc.root.element_children.map(&:name)
          expect(names.index("stream")).to eq 0 if names.include?("stream")
          expect((names - ["stream"]).first).to eq "front"
          expect(names - %w[stream front annotation refcontent seriesInfo])
            .to be_empty
        end

        it "orders <front> children per RFC 7991 2.26" do
          order = %w[title seriesInfo author date area workgroup keyword
                     abstract note boilerplate toc]
          names = doc.at("front").element_children.map(&:name)
          expect(names).to eq names.sort_by { |n| order.index(n) }
        end

        it "has at least one author" do
          expect(doc.xpath("//front/author")).not_to be_empty
        end

        it "gives every seriesInfo both a name and a value" do
          doc.xpath("//seriesInfo").each do |si|
            expect(si["name"]).not_to be_nil
            expect(si["value"]).not_to be_nil
          end
        end

        it "emits no deprecated <format>" do
          expect(doc.xpath("//format")).to be_empty
        end
      end
    end
  end

  describe "seriesInfo status/stream fidelity" do
    let(:input) do
      <<~XML
        <reference anchor="RFC1">
          <stream>IETF</stream>
          <front>
            <title>Title</title>
            <seriesInfo name="RFC" value="1" status="Informational"/>
            <author><organization abbrev="IETF" ascii="Internet Engineering Task Force">Internet Engineering Task Force</organization></author>
          </front>
        </reference>
      XML
    end
    let(:item) { described_class.to_item(input) }
    subject { v3_xml(item) }

    it "re-emits the seriesInfo the parser folded into docidentifier + status" do
      expect(subject).to include '<seriesInfo name="RFC" value="1"'
    end

    it "writes back the status it parsed" do
      expect(subject).to include 'status="Informational"'
    end

    it "round-trips the stream element" do
      expect(subject).to include "<stream>IETF</stream>"
    end

    it "round-trips to an equivalent reference" do
      expect(subject).to be_equivalent_to input
    end
  end
end
