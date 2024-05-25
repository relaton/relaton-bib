describe RelatonBib::Place do
  it "raise ArgumentError" do
    expect do
      described_class.new
    end.to raise_error ArgumentError
  end

  describe RelatonBib::Place::RegionType do
    context "raise ArgumentError" do
      it "when name is nil adn ISO code is nil" do
        expect do
          described_class.new
        end.to raise_error ArgumentError
      end

      it "when name is nil and ISO code is invalid" do
        expect do
          described_class.new iso: "invalid"
        end.to raise_error ArgumentError
      end
    end

    context "create instance" do
      it "with name" do
        expect(described_class.new(name: "name").name).to eq "name"
      end

      it "with name and ISO code" do
        region = described_class.new(name: "name", iso: "WA")
        expect(region.name).to eq "name"
        expect(region.iso).to eq "WA"
      end

      it "with valid ISO code" do
        region = described_class.new(iso: "WA")
        expect(region.iso).to eq "WA"
        expect(region.name).to eq "Washington"
      end
    end
  end
end
