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

  # Reported against the metanorma-ietf transformer corpus (PR #125 review).
  describe "contract robustness" do
    it "renders an item built by from_xml with no collections" do
      item = Relaton::Bib::Item.from_xml "<bibitem id='X'><title>T</title></bibitem>"
      expect { v3_xml(item) }.not_to raise_error
      expect(item.to_rfcxml).to include "<reference"
    end

    it "tolerates a uri with no type attribute" do
      item = Relaton::Bib::Item.from_xml(
        "<bibitem id='ISO712'><title>T</title><uri>http://e.com</uri></bibitem>",
      )
      expect { v3_xml(item) }.not_to raise_error
      expect { item.to_rfcxml }.not_to raise_error
    end

    it "falls back to an HTML uri for the target when there is no src" do
      yaml = "id: X\ndocnumber: X\ntitle:\n  - content: T\n" \
             "source:\n  - type: HTML\n    content: http://e.com\next:\n"
      expect(v3_xml(item_from(yaml))).to include 'target="http://e.com"'
    end

    it "prefers src over an HTML uri" do
      yaml = "id: X\ndocnumber: X\ntitle:\n  - content: T\nsource:\n" \
             "  - type: HTML\n    content: http://html.example\n" \
             "  - type: src\n    content: http://src.example\next:\n"
      expect(v3_xml(item_from(yaml))).to include 'target="http://src.example"'
    end

    it "omits ascii attributes when folding leaves no letters" do
      yaml = "id: G\ndocnumber: G\ntitle:\n  - content: T\ncontributor:\n" \
             "  - person:\n      name:\n        completename:\n" \
             "          content: Νίκος Παπαδόπουλος\n" \
             "        formatted_initials:\n          content: Ν.\next:\n"
      author = Nokogiri::XML(v3_xml(item_from(yaml))).at("//author")
      expect(author["asciiFullname"]).to be_nil
      expect(author["asciiInitials"]).to be_nil
      expect(author["fullname"]).to eq "Νίκος Παπαδόπουλος"
    end

    it "unwraps semantic paragraphs carrying attributes in the abstract" do
      yaml = %(id: X\ndocnumber: X\ntitle:\n  - content: T\nabstract:\n) +
             %(  - content: '<p id="_349">First.</p><p>Second.</p>'\n) +
             %(    format: text/html\next:\n)
      doc = Nokogiri::XML(v3_xml(item_from(yaml)))
      expect(doc.xpath("//abstract/t").map(&:text)).to eq ["First.", "Second."]
      expect(doc.at("//abstract").to_xml).not_to include "<p"
    end
  end

  describe "contributor roles" do
    def contributors(extra)
      item_from(<<~YAML)
        id: R
        docnumber: R
        title:
          - content: T
        contributor:
        #{extra}
        ext:
      YAML
    end

    let(:rfc) do
      contributors(<<~Y.chomp)
          - person:
              name:
                completename:
                  content: S. Bradner
            role:
              - type: author
          - organization:
              name:
                - content: RFC Publisher
            role:
              - type: publisher
          - organization:
              name:
                - content: RFC Series
            role:
              - type: authorizer
      Y
    end

    it "does not render publisher or authorizer as authors when an author exists" do
      xml = v3_xml(rfc)
      expect(xml).to include 'fullname="S. Bradner"'
      expect(xml).not_to include "RFC Publisher"
      expect(xml).not_to include "RFC Series"
    end

    it "falls back to the wider role set when there is no author or editor" do
      item = contributors(<<~Y.chomp)
          - person:
              name:
                completename:
                  content: A. Translator
            role:
              - type: translator
      Y
      expect(v3_xml(item)).to include 'fullname="A. Translator"'
    end

    it "keeps editors alongside authors" do
      item = contributors(<<~Y.chomp)
          - person:
              name:
                completename:
                  content: E. Ditor
            role:
              - type: editor
      Y
      expect(v3_xml(item)).to include 'role="editor"'
    end

    it "treats a role-less contributor as an author" do
      item = contributors(<<~Y.chomp)
          - person:
              name:
                completename:
                  content: N. Orole
      Y
      expect(v3_xml(item)).to include 'fullname="N. Orole"'
    end
  end

  describe "identifier deduplication" do
    it "emits one seriesInfo when two docidentifiers spell the same id" do
      yaml = "id: R\ndocnumber: R\ntitle:\n  - content: T\ncontributor:\n" \
             "  - organization:\n      name:\n        - content: IETF\n" \
             "docidentifier:\n  - content: RFC 2119\n    type: IETF\n" \
             "    primary: true\n  - content: RFC2119\n    type: IETF\next:\n"
      expect(v3_xml(item_from(yaml)).scan("<seriesInfo").size).to eq 1
    end

    it "does not repeat in refcontent what seriesInfo already states" do
      yaml = "id: R\ndocnumber: R\ntitle:\n  - content: T\ncontributor:\n" \
             "  - organization:\n      name:\n        - content: ISO\n" \
             "docidentifier:\n  - content: RFC 2119\n    type: IETF\n" \
             "    primary: true\nseries:\n  - number: \"2119\"\n" \
             "    title:\n      - content: RFC\next:\n"
      xml = v3_xml(item_from(yaml))
      expect(xml).to include '<seriesInfo name="RFC" value="2119"/>'
      expect(xml).not_to include "<refcontent>"
    end
  end

  describe "compound titles" do
    let(:parts) do
      "  - type: title-intro\n    content: IT Security techniques\n" \
      "  - type: title-main\n    content: Hash-functions\n" \
      "  - type: title-part\n    content: 'Part 3: Dedicated hash-functions'\n"
    end

    it "prefers the composite main title" do
      yaml = "id: I\ndocnumber: I\ntitle:\n#{parts}" \
             "  - type: main\n    content: IT Security - Hash - Part 3\next:\n"
      expect(v3_xml(item_from(yaml)))
        .to include "<title>IT Security - Hash - Part 3</title>"
    end

    it "joins intro, main and part when there is no composite" do
      yaml = "id: I\ndocnumber: I\ntitle:\n#{parts}ext:\n"
      expect(v3_xml(item_from(yaml))).to include(
        "<title>IT Security techniques - Hash-functions - " \
        "Part 3: Dedicated hash-functions</title>",
      )
    end

    it "falls back to the first title when there are no parts" do
      yaml = "id: I\ndocnumber: I\ntitle:\n  - content: Only one\next:\n"
      expect(v3_xml(item_from(yaml))).to include "<title>Only one</title>"
    end

    it "flattens inline markup, which v3 <title> cannot carry" do
      yaml = %(id: g\ndocnumber: g\nformattedref:\n) +
             %(  content: 'G. Chapman. <em>Holy Grail</em>. <link target="http://e.com"/>'\next:\n)
      title = Nokogiri::XML(v3_xml(item_from(yaml))).at("//title")
      expect(title.to_xml).not_to include "<em>"
      expect(title.text).to eq "G. Chapman. Holy Grail."
    end
  end

  describe "Internet-Draft identifiers" do
    let(:item) do
      item_from(<<~YAML)
        id: D
        docnumber: I-D.aboba-context-802
        title:
          - content: T
        contributor:
          - organization:
              name:
                - content: IETF
        docidentifier:
          - content: I-D.aboba-context-802
            type: Internet-Draft
          - content: draft-aboba-context-802-00
            type: Internet-Draft
            primary: true
        ext:
      YAML
    end
    subject { v3_xml(item) }

    # xml2rfc only resolves the reference with the full draft name.
    it "puts the full draft name in seriesInfo" do
      expect(subject).to include(
        '<seriesInfo name="Internet-Draft" value="draft-aboba-context-802-00"/>',
      )
    end

    it "drops the I-D. anchor form rather than emitting it as refcontent" do
      expect(subject).not_to include "<refcontent>"
      expect(subject).not_to include "I-D.aboba-context-802</"
    end
  end

  describe "refcontent eligibility" do
    it "excludes URN identifiers, which double the readable one" do
      yaml = "id: I\ndocnumber: I\ntitle:\n  - content: T\ndocidentifier:\n" \
             "  - content: ISO/IEC 10118-3\n    type: ISO\n    primary: true\n" \
             "  - content: 'urn:iso:std:iso-iec:10118'\n    type: URN\next:\n"
      xml = v3_xml(item_from(yaml))
      expect(xml).to include "<refcontent>ISO/IEC 10118-3</refcontent>"
      expect(xml).not_to include "urn:iso"
    end

    it "suppresses an untyped identifier that just echoes the label" do
      yaml = "id: ZELLER\ndocnumber: ZELLER\ntitle:\n" \
             "  - content: Why Programs Fail\ndocidentifier:\n" \
             "  - content: ZELLER\n    primary: true\next:\n"
      expect(v3_xml(item_from(yaml))).not_to include "<refcontent>"
    end

    it "keeps the label when the reference has nothing else to show" do
      yaml = "id: ZELLER\ndocnumber: ZELLER\ndocidentifier:\n" \
             "  - content: ZELLER\n    primary: true\next:\n"
      expect(v3_xml(item_from(yaml))).to include "<refcontent>ZELLER</refcontent>"
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
