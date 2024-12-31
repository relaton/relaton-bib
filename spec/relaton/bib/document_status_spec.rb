describe Relaton::Bib::Status do
  it "create with hash" do
    ds = described_class.new stage: { content: "30", abbreviation: "CD" }
    expect(ds.stage).to be_instance_of Relaton::Bib::Status::Stage
    expect(ds.stage.content).to eq "30"
    expect(ds.stage.abbreviation).to eq "CD"
  end

  it "create with string" do
    ds = described_class.new stage: "30-CD"
    expect(ds.stage).to be_instance_of Relaton::Bib::Status::Stage
    expect(ds.stage.content).to eq "30-CD"
  end
end
