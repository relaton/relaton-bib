describe Relaton::Bib::Place do
  xit "raise ArgumentError" do
    expect do
      described_class.new
    end.to raise_error ArgumentError
  end

  describe Relaton::Bib::Place::RegionType do
    context "raise ArgumentError" do
      xit "when name is nil adn ISO code is nil" do
        expect do
          described_class.new
        end.to raise_error ArgumentError
      end

      xit "when name is nil and ISO code is invalid" do
        expect do
          described_class.new iso: "invalid"
        end.to raise_error ArgumentError
      end
    end

    context "create instance" do
      it "with name" do
        expect(described_class.new(content: "name").content).to eq "name"
      end

      it "with name and ISO code" do
        region = described_class.new(content: "name", iso: "WA")
        expect(region.content).to eq "name"
        expect(region.iso).to eq "WA"
      end

      it "with valid ISO code" do
        region = described_class.new(iso: "WA")
        expect(region.iso).to eq "WA"
        expect(region.content).to eq "Washington"
      end
    end
  end
end
