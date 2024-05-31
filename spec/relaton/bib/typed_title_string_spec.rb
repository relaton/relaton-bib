describe Relaton::Bib::TypedTitleString do
  # it "raises invalid type argument error" do
  #   expect do
  #     described_class.new type: "type", content: "title"
  #   end.to output(/title type "type" is invalid/).to_stderr
  # end

  it "raises missed title or content argument error" do
    expect { described_class.new }.to raise_error ArgumentError
  end

  context "instance" do
    subject do
      title = Relaton::Bib::FormattedString.new(content: "Title", format: nil)
      described_class.new type: "main", title: title
    end

    it "create instance without exeption" do
      expect(subject).to be_instance_of Relaton::Bib::TypedTitleString
    end

    it "create instance with title as hash" do
      subj = described_class.new(
        title: { content: "Title", language: "en", script: "Latn", format: "text/plain" },
      )
      expect(subj.title).to be_instance_of Relaton::Bib::FormattedString
      expect(subj.title.content).to eq "Title"
      expect(subj.title.language).to eq ["en"]
      expect(subj.title.script).to eq ["Latn"]
      expect(subj.title.format).to eq "text/plain"
    end

    it "return hash when title is string" do
      expect(subject.to_hash).to eq("type" => "main", "content" => "Title")
    end
  end

  context "create title-intro, title-main, title-part from string" do
    it "empty" do
      t = described_class.from_string ""
      expect(t.size).to eq 2
      expect(t[0].title.content).to eq ""
      expect(t[0].type).to eq "title-main"
      expect(t[1].title.content).to eq ""
      expect(t[1].type).to eq "main"
    end

    it "with main" do
      t = described_class.from_string "Main"
      expect(t.size).to eq 2
      expect(t[0].title.content).to eq "Main"
      expect(t[0].type).to eq "title-main"
      expect(t[1].title.content).to eq "Main"
      expect(t[1].type).to eq "main"
    end

    it "with main & part" do
      t = described_class.from_string "Main - Part 1:"
      expect(t.size).to eq 3
      expect(t[0].title.content).to eq "Main"
      expect(t[0].type).to eq "title-main"
      expect(t[1].title.content).to eq "Part 1:"
      expect(t[1].type).to eq "title-part"
      expect(t[2].title.content).to eq "Main - Part 1:"
      expect(t[2].type).to eq "main"
    end

    it "with intro & main" do
      t = described_class.from_string "Intro - Main"
      expect(t.size).to eq 3
      expect(t[0].title.content).to eq "Intro"
      expect(t[0].type).to eq "title-intro"
      expect(t[1].title.content).to eq "Main"
      expect(t[1].type).to eq "title-main"
      expect(t[2].title.content).to eq "Intro - Main"
      expect(t[2].type).to eq "main"
    end

    it "with intro & main & part" do
      t = described_class.from_string "Intro - Main - Part 1:"
      expect(t.size).to eq 4
      expect(t[0].title.content).to eq "Intro"
      expect(t[0].type).to eq "title-intro"
      expect(t[1].title.content).to eq "Main"
      expect(t[1].type).to eq "title-main"
      expect(t[2].title.content).to eq "Part 1:"
      expect(t[2].type).to eq "title-part"
      expect(t[3].title.content).to eq "Intro - Main - Part 1:"
      expect(t[3].type).to eq "main"
    end

    it "with extra part" do
      t = described_class.from_string "Intro - Main - Part 1: - Extra"
      expect(t.size).to eq 4
      expect(t[0].title.content).to eq "Intro"
      expect(t[0].type).to eq "title-intro"
      expect(t[1].title.content).to eq "Main"
      expect(t[1].type).to eq "title-main"
      expect(t[2].title.content).to eq "Part 1: -- Extra"
      expect(t[2].type).to eq "title-part"
      expect(t[3].title.content).to eq "Intro - Main - Part 1: -- Extra"
      expect(t[3].type).to eq "main"
    end
  end
end
