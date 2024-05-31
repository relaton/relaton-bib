describe Relaton::Bib::DocumentStatus do
  it "create with hash" do
    ds = described_class.new stage: { value: "30", abbreviation: "CD" }
    expect(ds.stage).to be_instance_of Relaton::Bib::DocumentStatus::Stage
    expect(ds.stage.value).to eq "30"
    expect(ds.stage.abbreviation).to eq "CD"
  end

  it "create with string" do
    ds = described_class.new stage: "30-CD"
    expect(ds.stage).to be_instance_of Relaton::Bib::DocumentStatus::Stage
    expect(ds.stage.value).to eq "30-CD"
  end
end
