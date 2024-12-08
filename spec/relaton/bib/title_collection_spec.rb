describe Relaton::Bib::TitleCollection do
  context "create title-intro, title-main, title-part from string" do
    context "empty" do
      subject { described_class.from_string "" }
      it { is_expected.to be_instance_of described_class }
      it { expect(subject[0].content).to eq "" }
      it { expect(subject[0].type).to eq "title-main" }
      it { expect(subject[1].content).to eq "" }
      it { expect(subject[1].type).to eq "main" }
    end

    context "with main" do
      subject { described_class.from_string "Main" }
      it { expect(subject[0].content).to eq "Main" }
      it { expect(subject[0].type).to eq "title-main" }
      it { expect(subject[1].content).to eq "Main" }
      it { expect(subject[1].type).to eq "main" }
    end

    context "with main & part" do
      subject { described_class.from_string "Main - Part 1:" }
      it { expect(subject[0].content).to eq "Main" }
      it { expect(subject[0].type).to eq "title-main" }
      it { expect(subject[1].content).to eq "Part 1:" }
      it { expect(subject[1].type).to eq "title-part" }
      it { expect(subject[2].content).to eq "Main - Part 1:" }
      it { expect(subject[2].type).to eq "main" }
    end

    context "with intro & main" do
      subject { described_class.from_string "Intro - Main" }
      it { expect(subject[0].content).to eq "Intro" }
      it { expect(subject[0].type).to eq "title-intro" }
      it { expect(subject[1].content).to eq "Main" }
      it { expect(subject[1].type).to eq "title-main" }
      it { expect(subject[2].content).to eq "Intro - Main" }
      it { expect(subject[2].type).to eq "main" }
    end

    context "with intro & main & part" do
      subject { described_class.from_string "Intro - Main - Part 1:" }
      it { expect(subject[0].content).to eq "Intro" }
      it { expect(subject[0].type).to eq "title-intro" }
      it { expect(subject[1].content).to eq "Main" }
      it { expect(subject[1].type).to eq "title-main" }
      it { expect(subject[2].content).to eq "Part 1:" }
      it { expect(subject[2].type).to eq "title-part" }
      it { expect(subject[3].content).to eq "Intro - Main - Part 1:" }
      it { expect(subject[3].type).to eq "main" }
    end

    context "with extra part" do
      subject { described_class.from_string "Intro - Main - Part 1: - Extra" }
      it { expect(subject[0].content).to eq "Intro" }
      it { expect(subject[0].type).to eq "title-intro" }
      it { expect(subject[1].content).to eq "Main" }
      it { expect(subject[1].type).to eq "title-main" }
      it { expect(subject[2].content).to eq "Part 1: -- Extra" }
      it { expect(subject[2].type).to eq "title-part" }
      it { expect(subject[3].content).to eq "Intro - Main - Part 1: -- Extra" }
      it { expect(subject[3].type).to eq "main" }
    end
  end
end
