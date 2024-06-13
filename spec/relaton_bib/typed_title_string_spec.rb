RSpec.describe RelatonBib::TypedTitleString do
  # it "raises invalid type argument error" do
  #   expect do
  #     RelatonBib::TypedTitleString.new type: "type", content: "title"
  #   end.to output(/title type "type" is invalid/).to_stderr
  # end

  it "raises missed title or content argument error" do
    expect { RelatonBib::TypedTitleString.new }.to raise_error ArgumentError
  end

  context "instance" do
    subject do
      RelatonBib::TypedTitleString.new(
        type: "main",
        content: RelatonBib::Element::TextElement.parse("Title"),
      )
    end

    it "create instance without exeption" do
      expect(subject).to be_instance_of RelatonBib::TypedTitleString
    end

    # it "create instance with title as hash" do
    #   subj = RelatonBib::TypedTitleString.new(
    #     title: { content: "Title", language: "en", script: "Latn", format: "text/plain" },
    #   )
    #   expect(subj.title).to be_instance_of RelatonBib::FormattedString
    #   expect(subj.title.content).to eq "Title"
    #   expect(subj.title.language).to eq ["en"]
    #   expect(subj.title.script).to eq ["Latn"]
    #   expect(subj.title.format).to eq "text/plain"
    # end

    it "return hash when title is string" do
      expect(subject.to_h).to eq("type" => "main", "content" => "Title")
    end

    context "set content" do
      it "with string" do
        subject.content = "New title"
        expect(subject.content[0]).to be_instance_of RelatonBib::Element::Text
        expect(subject.to_s).to eq "New title"
      end

      it "with elemets" do
        subject.content = RelatonBib::Element::TextElement.parse("New title")
        expect(subject.content[0]).to be_instance_of RelatonBib::Element::Text
        expect(subject.to_s).to eq "New title"
      end
    end
  end

  context "create title-intro, title-main, title-part from string" do
    it "empty" do
      t = RelatonBib::TypedTitleString.from_string ""
      expect(t.size).to eq 2
      expect(t[0].to_s).to eq ""
      expect(t[0].type).to eq "title-main"
      expect(t[1].to_s).to eq ""
      expect(t[1].type).to eq "main"
    end

    it "with main" do
      t = RelatonBib::TypedTitleString.from_string "Main"
      expect(t.size).to eq 2
      expect(t[0].to_s).to eq "Main"
      expect(t[0].type).to eq "title-main"
      expect(t[1].to_s).to eq "Main"
      expect(t[1].type).to eq "main"
    end

    it "with main & part" do
      t = RelatonBib::TypedTitleString.from_string "Main - Part 1:"
      expect(t.size).to eq 3
      expect(t[0].to_s).to eq "Main"
      expect(t[0].type).to eq "title-main"
      expect(t[1].to_s).to eq "Part 1:"
      expect(t[1].type).to eq "title-part"
      expect(t[2].to_s).to eq "Main - Part 1:"
      expect(t[2].type).to eq "main"
    end

    it "with intro & main" do
      t = RelatonBib::TypedTitleString.from_string "Intro - Main"
      expect(t.size).to eq 3
      expect(t[0].to_s).to eq "Intro"
      expect(t[0].type).to eq "title-intro"
      expect(t[1].to_s).to eq "Main"
      expect(t[1].type).to eq "title-main"
      expect(t[2].to_s).to eq "Intro - Main"
      expect(t[2].type).to eq "main"
    end

    it "with intro & main & part" do
      t = RelatonBib::TypedTitleString.from_string "Intro - Main - Part 1:"
      expect(t.size).to eq 4
      expect(t[0].to_s).to eq "Intro"
      expect(t[0].type).to eq "title-intro"
      expect(t[1].to_s).to eq "Main"
      expect(t[1].type).to eq "title-main"
      expect(t[2].to_s).to eq "Part 1:"
      expect(t[2].type).to eq "title-part"
      expect(t[3].to_s).to eq "Intro - Main - Part 1:"
      expect(t[3].type).to eq "main"
    end

    it "with extra part" do
      t = RelatonBib::TypedTitleString.from_string "Intro - Main - Part 1: - Extra"
      expect(t.size).to eq 4
      expect(t[0].to_s).to eq "Intro"
      expect(t[0].type).to eq "title-intro"
      expect(t[1].to_s).to eq "Main"
      expect(t[1].type).to eq "title-main"
      expect(t[2].to_s).to eq "Part 1: -- Extra"
      expect(t[2].type).to eq "title-part"
      expect(t[3].to_s).to eq "Intro - Main - Part 1: -- Extra"
      expect(t[3].type).to eq "main"
    end
  end
end
