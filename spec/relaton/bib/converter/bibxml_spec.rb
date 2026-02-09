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
      expect(subject.docidentifier[0].primary).to be true
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
