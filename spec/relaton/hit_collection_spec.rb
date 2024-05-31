describe Relaton::HitCollection do
  subject do
    hits = described_class.new("ref")
    hit = Relaton::Bib::Hit.new({})
    item = double "bibitem"
    expect(item).to receive(:to_xml).at_most :once
    expect(hit).to receive(:fetch).and_return(item).at_most :twice
    hits << hit
    hits
  end

  it("fetches all hits") { subject.fetch }

  it "select hits" do
    expect(subject.select).to be_instance_of Relaton::HitCollection
  end

  it "collection to xml" do
    expect(subject.to_xml).to eq %{<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<documents/>\n}
  end

  it "reduce collection" do
    subject.reduce!([]) { |sum, hit| sum << hit }
    expect(subject).to be_instance_of Relaton::HitCollection
  end

  it "returns string" do
    expect(subject.to_s).to eq(
      "<Relaton::HitCollection:#{format('%#.14x', subject.object_id << 1)} "\
      "@ref=ref @fetched=false>",
    )
  end
end
