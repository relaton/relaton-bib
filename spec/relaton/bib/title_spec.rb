describe Relaton::Bib::Title do
  context "from xml" do
    let(:xml) do
      <<~XML
        <title type="main" language="en" script="Latn" locale="EN-us">Title</title>
      XML
    end

    subject { Relaton::Model::Title.from_xml xml }
    it { is_expected.to be_instance_of described_class }
    it { expect(subject.content).to eq "Title" }
    it { expect(subject.language).to eq "en" }
    it { expect(subject.script).to eq "Latn" }
    it { expect(subject.locale).to eq "EN-us" }
  end
end
