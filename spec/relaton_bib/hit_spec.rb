RSpec.describe RelatonBib::Hit do
  subject { RelatonBib::Hit.new({}) }

  it "returns string" do
    expect(subject.to_s).to eq(
      "<RelatonBib::Hit:#{format('%#.14x', subject.object_id << 1)} "\
      '@text="" @fetched="false" @fullIdentifier="" @title="">',
    )
  end

  it "to xml" do
    item = double
    expect(item).to receive(:to_xml).and_return "<bibdata></bibdata>"
    expect(subject).to receive(:fetch).and_return item
    expect(subject.to_xml).to eq "<bibdata></bibdata>"
  end
end
