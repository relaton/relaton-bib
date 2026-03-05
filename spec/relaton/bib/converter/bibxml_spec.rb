describe Relaton::Bib::Converter::BibXml do
  context "Reference XML roundtrip" do
    let(:input) { File.read "spec/fixtures/rfc.xml", encoding: "utf-8" }
    let(:item) { described_class.to_item(input) }
    subject { described_class.from_item(item).to_xml }
    it { is_expected.to be_equivalent_to input }
  end

  context "Referencegroup XML roundtrip" do
    let(:input) { File.read "spec/fixtures/bcp.xml", encoding: "utf-8" }
    let(:item) { described_class.to_item(input) }
    subject { described_class.from_item(item).to_xml }
    it { is_expected.to be_equivalent_to input }
  end

  context "YAML to Reference XML" do
    let(:item) { Relaton::Bib::Item.from_yaml File.read("spec/fixtures/rfc.yml") }
    let(:file) { "spec/fixtures/rfc.xml" }
    subject { described_class.from_item(item).to_xml }
    it { is_expected.to be_equivalent_to File.read(file, encoding: "UTF-8") }
  end

  context "YAML to Referencegroup XML" do
    let(:item) { Relaton::Bib::Item.from_yaml File.read("spec/fixtures/bcp.yml") }
    let(:file) { "spec/fixtures/bcp.xml" }
    subject { described_class.from_item(item).to_xml }
    it { is_expected.to be_equivalent_to File.read(file, encoding: "UTF-8") }
  end

  context "IEEE BibXML" do
    let(:input) { File.read "spec/fixtures/ieee_bibxml.xml", encoding: "utf-8" }
    let(:item) { described_class.to_item(input) }

    it "parses IEEE reference" do
      expect(item).to be_a Relaton::Bib::ItemData
      expect(item.title[0].content).to include("Health informatics")
      expect(item.docidentifier[0].content).to eq "IEEE 11073-10201-2020"
      expect(item.date[0].type).to eq "published"
      expect(item.abstract[0].content).to include("ISO/IEEE 11073")
    end

    it "converts IEEE reference back to XML" do
      xml = described_class.from_item(item).to_xml
      expect(xml).to include("IEEE")
      expect(xml).to include("Health informatics")
      expect(xml).to include("10.1109/IEEESTD.2020.9102466")
    end
  end

  describe ".from_item" do
    let(:item) { Relaton::Bib::Item.from_yaml File.read("spec/fixtures/rfc.yml") }
    subject { described_class.from_item(item) }

    it "returns Rfcxml::V3::Reference" do
      expect(subject).to be_a Rfcxml::V3::Reference
    end
  end

  describe ".to_item" do
    let(:xml) { File.read "spec/fixtures/rfc.xml", encoding: "utf-8" }
    subject { described_class.to_item(xml) }

    it "returns ItemData" do
      expect(subject).to be_a Relaton::Bib::ItemData
    end

    it "sets type to standard" do
      expect(subject.type).to eq "standard"
    end

    it "parses docidentifiers" do
      expect(subject.docidentifier).not_to be_empty
      primary = subject.docidentifier.find(&:primary)
      expect(primary).not_to be_nil
    end

    it "populates person forename from initials" do
      xml = <<~XML
        <reference anchor="RFC0001">
          <front>
            <title>Test</title>
            <author initials="A. B." surname="Smith" fullname="Arnold B Smith"/>
            <date year="2024"/>
          </front>
        </reference>
      XML
      item = described_class.to_item(xml)
      person = item.contributor.first.person
      expect(person.name.forename.size).to eq 2
      expect(person.name.forename[0].initial).to eq "A"
      expect(person.name.forename[1].initial).to eq "B"
    end
  end

  describe "FromRfcxml#docidentifiers" do
    context "with RFC prefix anchor and no seriesInfo" do
      let(:xml) do
        <<~XML
          <reference anchor="RFC0001">
            <front>
              <title>Test RFC</title>
              <date year="2014"/>
            </front>
          </reference>
        XML
      end
      let(:item) { described_class.to_item(xml) }

      it "creates a single primary docid with stripped leading zeros" do
        expect(item.docidentifier.size).to eq 1
        primary = item.docidentifier.first
        expect(primary.primary).to be true
        expect(primary.content).to eq "RFC 1"
        expect(primary.type).to eq "RFC"
      end
    end

    context "with BCP prefix anchor" do
      let(:xml) do
        <<~XML
          <reference anchor="BCP0047">
            <front>
              <title>Test BCP</title>
              <date year="2020"/>
            </front>
          </reference>
        XML
      end
      let(:item) { described_class.to_item(xml) }

      it "creates a primary docid with BCP type and stripped zeros" do
        primary = item.docidentifier.find(&:primary)
        expect(primary.content).to eq "BCP 47"
        expect(primary.type).to eq "BCP"
      end
    end

    context "with Internet-Draft anchor (I-D prefix)" do
      let(:xml) do
        <<~XML
          <reference anchor="I-D.some-draft-name">
            <front>
              <title>Test Draft</title>
              <date year="2023"/>
            </front>
          </reference>
        XML
      end
      let(:item) { described_class.to_item(xml) }

      it "creates a primary docid with Internet-Draft type" do
        primary = item.docidentifier.find(&:primary)
        expect(primary.content).to eq "draft-some-draft-name"
        expect(primary.type).to eq "Internet-Draft"
      end
    end

    context "with draft prefix anchor" do
      let(:xml) do
        <<~XML
          <reference anchor="draft-ietf-proto-01">
            <front>
              <title>Test Draft</title>
              <date year="2023"/>
            </front>
          </reference>
        XML
      end
      let(:item) { described_class.to_item(xml) }

      it "creates a primary docid with Internet-Draft type" do
        primary = item.docidentifier.find(&:primary)
        expect(primary.content).to eq "draft-ietf-proto-01"
        expect(primary.type).to eq "Internet-Draft"
      end
    end

    context "with non-standard prefix anchor (IEEE)" do
      let(:xml) do
        <<~XML
          <reference anchor="IEEE.11073-10201-2020">
            <front>
              <title>IEEE Standard</title>
              <date year="2020"/>
            </front>
          </reference>
        XML
      end
      let(:item) { described_class.to_item(xml) }

      it "creates a primary docid with prefix as type" do
        primary = item.docidentifier.find(&:primary)
        expect(primary.content).to eq "IEEE 11073-10201-2020"
        expect(primary.type).to eq "IEEE"
      end
    end

    context "with W3C prefix anchor" do
      let(:xml) do
        <<~XML
          <reference anchor="W3C.REC-xml-20081126">
            <front>
              <title>W3C Recommendation</title>
              <date year="2008"/>
            </front>
          </reference>
        XML
      end
      let(:item) { described_class.to_item(xml) }

      it "creates a primary docid with W3C type" do
        primary = item.docidentifier.find(&:primary)
        expect(primary.content).to eq "W3C REC-xml-20081126"
        expect(primary.type).to eq "W3C"
      end
    end

    context "with Internet-Draft seriesInfo in front" do
      let(:xml) do
        <<~XML
          <reference anchor="RFC0001">
            <front>
              <title>Test RFC</title>
              <seriesInfo name="Internet-Draft" value="draft-ietf-somewg-proto-07"/>
              <date year="2014"/>
            </front>
          </reference>
        XML
      end
      let(:item) { described_class.to_item(xml) }

      it "marks the versioned Internet-Draft ID as primary" do
        draft_id = item.docidentifier.find { |d| d.type == "Internet-Draft" }
        expect(draft_id).not_to be_nil
        expect(draft_id.content).to eq "draft-ietf-somewg-proto-07"
        expect(draft_id.primary).to be true
      end

      it "does not mark the anchor-derived ID as primary" do
        anchor_id = item.docidentifier.find { |d| d.type == "RFC" }
        expect(anchor_id.primary).to be_falsey
      end
    end

    context "with Internet-Draft seriesInfo on reference" do
      let(:xml) do
        <<~XML
          <reference anchor="RFC0001">
            <front>
              <title>Test RFC</title>
              <date year="2014"/>
            </front>
            <seriesInfo name="Internet-Draft" value="draft-ietf-somewg-proto-07"/>
          </reference>
        XML
      end
      let(:item) { described_class.to_item(xml) }

      it "marks the versioned Internet-Draft ID as primary" do
        draft_id = item.docidentifier.find { |d| d.type == "Internet-Draft" }
        expect(draft_id).not_to be_nil
        expect(draft_id.content).to eq "draft-ietf-somewg-proto-07"
        expect(draft_id.primary).to be true
      end
    end

    context "with DOI seriesInfo in front" do
      let(:xml) do
        <<~XML
          <reference anchor="RFC0001">
            <front>
              <title>Test RFC</title>
              <seriesInfo name="DOI" value="10.17487/RFC0001"/>
              <date year="2014"/>
            </front>
          </reference>
        XML
      end
      let(:item) { described_class.to_item(xml) }

      it "adds a DOI docid" do
        doi = item.docidentifier.find { |d| d.type == "DOI" }
        expect(doi).not_to be_nil
        expect(doi.content).to eq "10.17487/RFC0001"
      end

      it "keeps the anchor-derived ID primary when no versioned ID exists" do
        primary = item.docidentifier.find(&:primary)
        expect(primary.type).to eq "RFC"
      end
    end

    context "with DOI seriesInfo on reference" do
      let(:xml) do
        <<~XML
          <reference anchor="IEEE.11073-10201-2020">
            <front>
              <title>IEEE Standard</title>
              <date year="2020"/>
            </front>
            <seriesInfo name="DOI" value="10.1109/IEEESTD.2020.9102466"/>
          </reference>
        XML
      end
      let(:item) { described_class.to_item(xml) }

      it "adds a DOI docid from reference-level seriesInfo" do
        doi = item.docidentifier.find { |d| d.type == "DOI" }
        expect(doi).not_to be_nil
        expect(doi.content).to eq "10.1109/IEEESTD.2020.9102466"
      end
    end

    context "with multiple identifier sources (RFC anchor + Internet-Draft + DOI)" do
      let(:xml) do
        <<~XML
          <reference anchor="RFC0001">
            <front>
              <title>Test RFC</title>
              <seriesInfo name="DOI" value="10.17487/RFC0001"/>
              <seriesInfo name="Internet-Draft" value="draft-ietf-somewg-proto-07"/>
              <date year="2014"/>
            </front>
          </reference>
        XML
      end
      let(:item) { described_class.to_item(xml) }

      it "includes RFC, Internet-Draft, and DOI identifiers" do
        expect(item.docidentifier.size).to eq 3
        types = item.docidentifier.map(&:type)
        expect(types).to include("RFC", "Internet-Draft", "DOI")
      end

      it "marks the versioned Internet-Draft ID as primary" do
        primaries = item.docidentifier.select(&:primary)
        expect(primaries.size).to eq 1
        expect(primaries.first.type).to eq "Internet-Draft"
        expect(primaries.first.content).to eq "draft-ietf-somewg-proto-07"
      end
    end
  end

  describe "FromRfcxmlReferencegroup#docidentifiers" do
    context "with BCP anchor" do
      let(:xml) do
        <<~XML
          <referencegroup anchor="BCP0001">
            <reference anchor="RFC0001">
              <front>
                <title>Included RFC</title>
                <date year="2014"/>
              </front>
            </reference>
          </referencegroup>
        XML
      end
      let(:item) { described_class.to_item(xml) }

      it "creates a single primary docid from the group anchor" do
        expect(item.docidentifier.size).to eq 1
        primary = item.docidentifier.first
        expect(primary.primary).to be true
        expect(primary.content).to eq "BCP 1"
        expect(primary.type).to eq "BCP"
      end
    end

    context "with STD anchor" do
      let(:xml) do
        <<~XML
          <referencegroup anchor="STD0068">
            <reference anchor="RFC5730">
              <front>
                <title>Included RFC</title>
                <date year="2009"/>
              </front>
            </reference>
          </referencegroup>
        XML
      end
      let(:item) { described_class.to_item(xml) }

      it "creates a primary docid with STD type" do
        primary = item.docidentifier.first
        expect(primary.content).to eq "STD 68"
        expect(primary.type).to eq "STD"
      end
    end

    context "with FYI anchor" do
      let(:xml) do
        <<~XML
          <referencegroup anchor="FYI0018">
            <reference anchor="RFC1578">
              <front>
                <title>Included RFC</title>
                <date year="1994"/>
              </front>
            </reference>
          </referencegroup>
        XML
      end
      let(:item) { described_class.to_item(xml) }

      it "creates a primary docid with FYI type" do
        primary = item.docidentifier.first
        expect(primary.content).to eq "FYI 18"
        expect(primary.type).to eq "FYI"
      end
    end
  end

  describe "FromRfcxml#organization" do
    context "when <organization> has an abbrev attribute" do
      let(:xml) do
        <<~XML
          <reference anchor="RFC0001">
            <front>
              <title>Test</title>
              <author>
                <organization abbrev="IETF">Internet Engineering Task Force</organization>
              </author>
              <date year="2024"/>
            </front>
          </reference>
        XML
      end
      let(:item) { described_class.to_item(xml) }

      it "creates an abbreviation with the abbrev value" do
        org = item.contributor.first.organization
        expect(org.abbreviation.content).to eq "IETF"
        expect(org.abbreviation.language).to eq "en"
      end
    end

    context "when <organization> has no abbrev attribute" do
      let(:xml) do
        <<~XML
          <reference anchor="RFC0002">
            <front>
              <title>Test</title>
              <author>
                <organization>W3C</organization>
              </author>
              <date year="2024"/>
            </front>
          </reference>
        XML
      end
      let(:item) { described_class.to_item(xml) }

      it "does not set an abbreviation" do
        org = item.contributor.first.organization
        expect(org.abbreviation).to be_nil
      end
    end
  end

  describe "ItemData#to_rfcxml integration" do
    let(:item) { Relaton::Bib::Item.from_yaml File.read("spec/fixtures/rfc.yml") }
    let(:expected) { File.read("spec/fixtures/rfc.xml", encoding: "UTF-8") }

    it "uses the converter" do
      expect(item.to_rfcxml).to be_equivalent_to expected
    end
  end
end
