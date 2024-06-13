describe RelatonBib::DocumentIdentifierUrn do
  context "ISO" do
    subject do
      described_class.new type: "URN", id: "urn:iso:std:iso:1111:-1:stage-60.60:ed-1:v1:en,fr"
    end

    it "remove part" do
      subject.remove_part
      expect(subject.id).to eq "urn:iso:std:iso:1111"
    end
  end

  context "IEC" do
    subject do
      described_class.new type: "URN", id: "urn:iec:std:iec:61058-2-4:1995::csv:en:plus:amd:1:2003"
    end

    it "remove part" do
      subject.remove_part
      expect(subject.id).to eq "urn:iec:std:iec:61058:1995::csv:en:plus:amd:1:2003"
    end

    it "remove date" do
      subject.remove_date
      expect(subject.id).to eq "urn:iec:std:iec:61058-2-4:::csv:en:plus:amd:1:2003"
    end

    it "set all parts" do
      subject.all_parts
      expect(subject.id).to eq "urn:iec:std:iec:61058-2-4:1995::ser"
    end
  end
end
