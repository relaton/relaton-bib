RSpec.describe RelatonBib::HitCollection do
  subject do
    hits = RelatonBib::HitCollection.new
    hit = RelatonBib::Hit.new({})
    item = double
    expect(hit).to receive(:fetch).and_return(item).at_most :once
    hits << hit
  end

  it "fetches all hits" do
    subject.fetch
  end

  it "returns string" do
    expect(subject.to_s).to eq(
      "<RelatonBib::HitCollection:#{format('%#.14x', subject.object_id << 1)} "\
      "@fetched=>",
    )
  end
end
