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
        title: RelatonBib::FormattedString.new(content: "Title", format: nil),
      )
    end

    it "create instance without exeption" do
      expect(subject).to be_instance_of RelatonBib::TypedTitleString
    end

    it "return hash when title is string" do
      expect(subject.to_hash).to eq("type" => "main", "content" => "Title")
    end
  end
end
