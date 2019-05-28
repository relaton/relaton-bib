RSpec.describe RelatonBib::WorkersPool do
  subject { RelatonBib::WorkersPool.new }

  it { expect(subject).to be_instance_of RelatonBib::WorkersPool }

  it "do jobs" do
    subject.worker { |n| n * 2 }
    (1..5).entries.each { |n| subject << n }
    expect(subject.size).to be_instance_of Integer
    subject.end
    result = subject.result
    expect(result).to eq [2, 4, 6, 8, 10]
  end
end
