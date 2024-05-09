RSpec.describe RelatonBib::DocumentIdentifier do
  context "instance methods" do
    subject { RelatonBib::DocumentIdentifier.new(id: "ISO 123") }
    it "#id=" do
      subject.id = "ISO 456"
      expect(subject.id.to_s).to eq "ISO 456"
    end
  end

  context "ISO" do
    subject do
      RelatonBib::DocumentIdentifier.new(id: "1111-2:2014", type: "ISO")
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

  context "GB" do
    subject do
      RelatonBib::DocumentIdentifier.new(id: "1111.2-2014", type: "Chinese Standard")
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
      subject = RelatonBib::DocumentIdentifier.new(id: "CIPM 43<sup>e</sup> réunion (1950)", type: "BIPM")
      xml = Nokogiri::XML::Builder.new do |builder|
        subject.to_xml(builder: builder, lang: "en")
      end.doc.root
      expect(xml.to_xml).to eq "<docidentifier type=\"BIPM\">CIPM 43<sup>e</sup> r&#xE9;union (1950)</docidentifier>"
    end
  end
end
