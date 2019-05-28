RSpec.describe RelatonBib::DocumentIdentifier do
  context "ISO" do
    subject { RelatonBib::DocumentIdentifier.new id: "1111-2:2014", type: "ISO" }

    it "remove part" do
      subject.remove_part
      expect(subject.id).to eq "1111:2014"
      subject.all_parts
      expect(subject.id).to eq "1111:2014 (all parts)"
    end

    it "remove date" do
      subject.remove_date
      expect(subject.id).to eq "1111-2"
    end
  end

  context "GB" do
    subject { RelatonBib::DocumentIdentifier.new id: "1111.2-2014", type: "Chinese Standard" }

    it "remove part" do
      subject.remove_part
      expect(subject.id).to eq "1111-2014"
    end

    it "remove date" do
      subject.remove_date
      expect(subject.id).to eq "1111.2"
    end
  end
end
