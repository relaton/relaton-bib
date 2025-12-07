describe Relaton::Bib::Title do
  context "create title-intro, title-main, title-part from string" do
    it "empty" do
      t = Relaton::Bib::Title.from_string ""
      expect(t.size).to eq 2
      expect(t[0].content).to eq ""
      expect(t[0].type).to eq "title-main"
      expect(t[1].content).to eq ""
      expect(t[1].type).to eq "main"
    end

    it "with main" do
      t = Relaton::Bib::Title.from_string "Main"
      expect(t.size).to eq 2
      expect(t[0].content).to eq "Main"
      expect(t[0].type).to eq "title-main"
      expect(t[1].content).to eq "Main"
      expect(t[1].type).to eq "main"
    end

    it "with main & part" do
      t = Relaton::Bib::Title.from_string "Main - Part 1:"
      expect(t.size).to eq 3
      expect(t[0].content).to eq "Main"
      expect(t[0].type).to eq "title-main"
      expect(t[1].content).to eq "Part 1:"
      expect(t[1].type).to eq "title-part"
      expect(t[2].content).to eq "Main - Part 1:"
      expect(t[2].type).to eq "main"
    end

    it "with intro & main" do
      t = Relaton::Bib::Title.from_string "Intro - Main"
      expect(t.size).to eq 3
      expect(t[0].content).to eq "Intro"
      expect(t[0].type).to eq "title-intro"
      expect(t[1].content).to eq "Main"
      expect(t[1].type).to eq "title-main"
      expect(t[2].content).to eq "Intro - Main"
      expect(t[2].type).to eq "main"
    end

    it "with intro & main & part" do
      t = Relaton::Bib::Title.from_string "Intro - Main - Part 1:"
      expect(t.size).to eq 4
      expect(t[0].content).to eq "Intro"
      expect(t[0].type).to eq "title-intro"
      expect(t[1].content).to eq "Main"
      expect(t[1].type).to eq "title-main"
      expect(t[2].content).to eq "Part 1:"
      expect(t[2].type).to eq "title-part"
      expect(t[3].content).to eq "Intro - Main - Part 1:"
      expect(t[3].type).to eq "main"
    end

    it "with extra part" do
      t = Relaton::Bib::Title.from_string "Intro - Main - Part 1: - Extra"
      expect(t.size).to eq 4
      expect(t[0].content).to eq "Intro"
      expect(t[0].type).to eq "title-intro"
      expect(t[1].content).to eq "Main"
      expect(t[1].type).to eq "title-main"
      expect(t[2].content).to eq "Part 1: -- Extra"
      expect(t[2].type).to eq "title-part"
      expect(t[3].content).to eq "Intro - Main - Part 1: -- Extra"
      expect(t[3].type).to eq "main"
    end
  end
end
