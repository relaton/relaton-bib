RSpec.describe RelatonBib::DocumentStatus do
  it "create with hash" do
    ds = RelatonBib::DocumentStatus.new stage: { value: "30", abbreviation: "CD" }
    expect(ds.stage).to be_instance_of RelatonBib::DocumentStatus::Stage
    expect(ds.stage.value).to eq "30"
    expect(ds.stage.abbreviation).to eq "CD"
  end
end
