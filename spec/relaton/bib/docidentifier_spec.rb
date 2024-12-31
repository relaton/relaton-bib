# encoding: UTF-8

describe Relaton::Bib::Docidentifier do
  context "parse" do
    let(:xml) do
      <<~XML
        <docidentifier language="en" script="Latn" locale="EN-us" type="BIPM" scope="part" primary="true">
          CIPM 43&lt;sup&gt;e&lt;/sup&gt; réunion (1950)
        </docidentifier>
      XML
    end
    subject { Relaton::Model::Docidentifier.from_xml xml }
    xit { expect(subject.content).to eq "CIPM 43<sup>e</sup> réunion (1950)" }
    it { expect(subject.type).to eq "BIPM" }
    it { expect(subject.scope).to eq "part" }
    xit { expect(subject.primary).to be true }
    it { expect(subject.language).to eq "en" }
    it { expect(subject.script).to eq "Latn" }
    it { expect(subject.locale).to eq "EN-us" }
  end

  context "ISO" do
    subject { described_class.new(content: "1111-2:2014", type: "ISO") }

    it "remove part" do
      subject.remove_part
      expect(subject.content).to eq "1111:2014"
      subject.all_parts
      expect(subject.content).to eq "1111:2014 (all parts)"
    end

    it "remove date" do
      subject.remove_date
      expect(subject.content).to eq "1111-2"
    end
  end

  context "URN" do
    context "ISO" do
      subject do
        described_class.new(
          type: "URN", content: "urn:iso:std:iso:1111:-1:stage-60.60:ed-1:v1:en,fr",
        )
      end

      it "remove part" do
        subject.remove_part
        expect(subject.content).to eq "urn:iso:std:iso:1111"
      end
    end

    context "IEC" do
      subject do
        described_class.new(
          type: "URN",
          content: "urn:iec:std:iec:61058-2-4:1995::csv:en:plus:amd:1:2003",
        )
      end

      it "remove part" do
        subject.remove_part
        expect(subject.content).to eq "urn:iec:std:iec:61058:1995::csv:en:plus:amd:1:2003"
      end

      it "remove date" do
        subject.remove_date
        expect(subject.content).to eq "urn:iec:std:iec:61058-2-4:::csv:en:plus:amd:1:2003"
      end

      it "set all parts" do
        subject.all_parts
        expect(subject.content).to eq "urn:iec:std:iec:61058-2-4:1995::ser"
      end
    end
  end

  context "GB" do
    subject do
      described_class.new(content: "1111.2-2014", type: "Chinese Standard")
    end

    it "remove part" do
      subject.remove_part
      expect(subject.content).to eq "1111-2014"
    end

    it "remove date" do
      subject.remove_date
      expect(subject.content).to eq "1111.2"
    end
  end

  context "#to_xml" do
    let(:subject) { described_class.new(content: "CIPM 43<sup>e</sup> réunion (1950)", type: "BIPM") }

    it do
      xml = Relaton::Model::Docidentifier.to_xml subject
      expect(xml).to eq "<docidentifier type=\"BIPM\">CIPM 43<sup>e</sup> réunion (1950)</docidentifier>"
    end
  end
end
