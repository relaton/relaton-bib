describe Relaton::Bib::Item do
  let(:input_yaml) { File.read("spec/fixtures/item.yaml", encoding: "UTF-8") }
  let(:item) { described_class.from_yaml input_yaml }

  it "round trip" do
    input_hash = YAML.safe_load input_yaml
    output_hash = YAML.safe_load described_class.to_yaml(item)
    expect(output_hash).to eq input_hash
  end
end
