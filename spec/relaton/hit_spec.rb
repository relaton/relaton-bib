describe Relaton::Hit do
  subject { described_class.new({}) }

  it "returns string" do
    expect(subject.to_s).to eq(
      "<Relaton::Hit:#{format('%#.14x', subject.object_id << 1)} " \
      '@text="" @fetched="false" @fullIdentifier="" @title="">',
    )
  end

  xit "to xml" do
    item = Relaton::Bib::Item.new
    expect(subject).to receive(:fetch).and_return item
    expect(subject.to_xml).to match(/<bibitem schema-version="v\d+\.\d+\.\d+"\/>/)
  end

  it "raise not implemented" do
    expect { subject.fetch }.to raise_error "Not implemented"
  end
end
