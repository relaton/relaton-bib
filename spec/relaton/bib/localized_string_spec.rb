describe Relaton::Bib::LocalizedString do
  context "instance" do
    subject { described_class.new(content: "content", language: "en", script: "Latn") }
    it { expect(subject.empty?).to be false }
    it { expect(subject.to_s).to eq "content" }
    it { expect(subject == described_class.new(content: "content", language: "en", script: "Latn")).to be true }
    it { expect(subject == described_class.new(content: "content", language: "en", script: "Cyrl")).to be false }
  end
end
