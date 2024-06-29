describe Relaton::Bib::Docidentifier do
  context "ISO" do
    subject do
      described_class.new(id: "1111-2:2014", type: "ISO")
    end

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

  context "URN" do
    context "ISO" do
      subject do
        described_class.new(
          type: "URN", id: "urn:iso:std:iso:1111:-1:stage-60.60:ed-1:v1:en,fr",
        )
      end

      it "remove part" do
        subject.remove_part
        expect(subject.id).to eq "urn:iso:std:iso:1111"
      end
    end

    context "IEC" do
      subject do
        described_class.new(
          type: "URN",
          id: "urn:iec:std:iec:61058-2-4:1995::csv:en:plus:amd:1:2003",
        )
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

  context "GB" do
    subject do
      described_class.new(id: "1111.2-2014", type: "Chinese Standard")
    end

    it "remove part" do
      subject.remove_part
      expect(subject.id).to eq "1111-2014"
    end

    it "remove date" do
      subject.remove_date
      expect(subject.id).to eq "1111.2"
    end
  end

  context "#to_xml" do
    it "with superscription" do
      subject = described_class.new(id: "CIPM 43<sup>e</sup> réunion (1950)", type: "BIPM")
      xml = Nokogiri::XML::Builder.new do |builder|
        subject.to_xml(builder: builder, lang: "en")
      end.doc.root
      expect(xml.to_xml).to eq "<docidentifier type=\"BIPM\">CIPM 43<sup>e</sup> r&#xE9;union (1950)</docidentifier>"
    end
  end
end
