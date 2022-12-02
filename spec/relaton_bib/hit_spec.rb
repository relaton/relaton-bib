RSpec.describe RelatonBib::Hit do
  subject { RelatonBib::Hit.new({}) }

  it "returns string" do
    expect(subject.to_s).to eq(
      "<RelatonBib::Hit:#{format('%#.14x', subject.object_id << 1)} " \
      '@text="" @fetched="false" @fullIdentifier="" @title="">',
    )
  end

  it "to xml" do
    item = RelatonBib::BibliographicItem.new
    expect(subject).to receive(:fetch).and_return item
    expect(subject.to_xml).to match(/<bibitem schema-version="v\d+\.\d+\.\d+"\/>/)
  end

  it "raise not implemented" do
    expect { subject.fetch }.to raise_error "Not implemented"
  end
end
