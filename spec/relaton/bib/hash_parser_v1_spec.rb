require "relaton/bib/hash_parser_v1"
describe Relaton::Bib::HashParserV1 do
  let(:output_file) { "spec/fixtures/item_from_v1.yaml" }
  let(:input_hash) { YAML.load_file "spec/fixtures/item_v1.yaml" }
  let(:bib_hash) { described_class.hash_to_bib input_hash }
  let(:item) { Relaton::Bib::ItemData.new(**bib_hash) }
  let(:output_yaml) { Relaton::Bib::Item.to_yaml item }
  let(:output_hash) { YAML.safe_load output_yaml }

  it "converts to XML" do
    xml = item.to_xml
    xml_file = "spec/fixtures/from_old_yaml.xml"
    File.write xml_file, xml, encoding: "UTF-8" unless File.exist? xml_file
    expected_xml = File.read(xml_file, encoding: "UTF-8")
    expect(xml).to be_equivalent_to expected_xml
  end

  it "parses hash to bib item" do
    File.write output_file, output_yaml, encoding: "UTF-8" unless File.exist? output_file
    expect(output_hash).to eq YAML.load_file(output_file)
  end

  describe "version_hash_to_bib" do
    it "parses version with year-only revision_date" do
      ret = { version: [{ revision_date: "2019", draft: "draft" }] }
      described_class.version_hash_to_bib(ret)
      expect(ret[:version].first).to be_instance_of Relaton::Bib::Version
      expect(ret[:version].first.revision_date).to eq Date.new(2019, 1, 1)
    end

    it "parses version with year-month revision_date" do
      ret = { version: [{ revision_date: "2019-04" }] }
      described_class.version_hash_to_bib(ret)
      expect(ret[:version].first.revision_date).to eq Date.new(2019, 4, 1)
    end

    it "parses version with full date revision_date" do
      ret = { version: [{ revision_date: "2019-04-01", draft: "draft" }] }
      described_class.version_hash_to_bib(ret)
      expect(ret[:version].first.revision_date).to eq Date.new(2019, 4, 1)
      expect(ret[:version].first.draft).to eq "draft"
    end

    it "handles nil version" do
      ret = { version: nil }
      described_class.version_hash_to_bib(ret)
      expect(ret[:version]).to be_nil
    end
  end

  describe "id_hash_to_bib" do
    it "strips non-word characters from id" do
      ret = { id: "ISO/IEC 27001:2022" }
      described_class.id_hash_to_bib(ret)
      expect(ret[:id]).to eq "ISOIEC270012022"
    end

    it "handles id with spaces and special characters" do
      ret = { id: "RFC 8341 (BCP 190)" }
      described_class.id_hash_to_bib(ret)
      expect(ret[:id]).to eq "RFC8341BCP190"
    end

    it "returns nil when id is not present" do
      ret = {}
      expect(described_class.id_hash_to_bib(ret)).to be_nil
      expect(ret[:id]).to be_nil
    end

    it "keeps id with only word characters unchanged" do
      ret = { id: "ABC123" }
      described_class.id_hash_to_bib(ret)
      expect(ret[:id]).to eq "ABC123"
    end
  end

  describe "parse edition as string" do
    let(:input_hash) { { edition: "1st ed." } }

    it "return Edition" do
      edition = described_class.edition_hash_to_bib input_hash
      expect(edition).to be_instance_of Relaton::Bib::Edition
      expect(edition.content).to eq "1st ed."
    end
  end
end
