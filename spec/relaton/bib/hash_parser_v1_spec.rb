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
end
