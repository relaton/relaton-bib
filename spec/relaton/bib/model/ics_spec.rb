describe Relaton::Bib::ICS do
  describe "#get_text" do
    context "when code is present and text is nil" do
      it "fetches description from Isoics" do
        ics = Relaton::Bib::ICS.new(code: "01.040.01")
        expect(ics.text).to eq "Generalities. Terminology. Standardization. Documentation (Vocabularies)"
      end
    end

    context "when code is present and text is empty" do
      it "fetches description from Isoics" do
        ics = Relaton::Bib::ICS.new(code: "01.040.01")
        ics.text = ""
        expect(ics.text).to eq "Generalities. Terminology. Standardization. Documentation (Vocabularies)"
      end
    end

    context "when code is nil" do
      it "returns nil" do
        ics = Relaton::Bib::ICS.new
        expect(ics.text).to be_nil
      end
    end

    context "when text is already set" do
      it "returns the set text" do
        ics = Relaton::Bib::ICS.new(code: "01.040.01")
        ics.text = "Custom text"
        expect(ics.text).to eq "Custom text"
      end
    end

    context "when code is invalid" do
      it "returns nil" do
        ics = Relaton::Bib::ICS.new(code: "invalid.code")
        expect(ics.text).to be_nil
      end
    end
  end
end
