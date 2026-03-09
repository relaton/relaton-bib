require "relaton/bib/hash_parser_v1"
describe Relaton::Bib::HashParserV1 do
  let(:output_file) { "spec/fixtures/item_from_v1.yaml" }
  let(:input_hash) { YAML.load_file "spec/fixtures/item_v1.yaml" }
  let(:bib_hash) { described_class.hash_to_bib input_hash }
  let(:item) { Relaton::Bib::ItemData.new(**bib_hash) }
  let(:output_yaml) { Relaton::Bib::Item.to_yaml item }
  let(:output_hash) { YAML.safe_load output_yaml }

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

  describe "parse edition as string" do
    let(:input_hash) { { edition: "1st ed." } }

    it "return Edition" do
      edition = described_class.edition_hash_to_bib input_hash
      expect(edition).to be_instance_of Relaton::Bib::Edition
      expect(edition.content).to eq "1st ed."
    end
  end
end
