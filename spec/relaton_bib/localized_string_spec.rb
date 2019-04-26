RSpec.describe RelatonBib::LocalizedString do
  subject { RelatonBib::LocalizedString.new "content", "en", "Latn" }

  it "returns false" do
    expect(subject.empty?).to be false  
  end
end
