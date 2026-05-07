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

  describe "XML serialization with Isoics fallback" do
    # These tests guard the round-trip behaviour that lets <ics><code>X</code></ics>
    # (with <text> absent from the source) re-serialize with the Isoics
    # description filled in. This relies on the Isoics fallback being
    # written through the public setter so lutaml-model marks the value as
    # "set" and emits it.

    context "ICS.new with a known code and no text" do
      it "emits the Isoics description as <text>" do
        ics = Relaton::Bib::ICS.new(code: "67.060")
        expect(ics.to_xml).to include(
          "<text>Cereals, pulses and derived products</text>",
        )
      end
    end

    context "ICS.from_xml standalone with no <text>" do
      it "fills in <text> from Isoics on re-serialization" do
        ics = Relaton::Bib::ICS.from_xml("<ics><code>67.060</code></ics>")
        expect(ics.to_xml).to include("<code>67.060</code>")
        expect(ics.to_xml).to include(
          "<text>Cereals, pulses and derived products</text>",
        )
      end
    end

    context "Ext.from_xml nesting an ICS with no <text>" do
      # This is the canonical metanorma collection round-trip path: the
      # ICS is reached as a nested-collection child of <ext>, not via
      # ICS.from_xml directly.
      it "fills in <text> from Isoics on re-serialization of the parent" do
        ext = Relaton::Bib::Ext.from_xml(
          "<ext><ics><code>67.060</code></ics></ext>",
        )
        expect(ext.to_xml).to include(
          "<text>Cereals, pulses and derived products</text>",
        )
      end
    end

    context "explicit text wins over Isoics" do
      it "emits the explicit text in standalone to_xml" do
        ics = Relaton::Bib::ICS.new(
          code: "67.060", text: "Custom override text",
        )
        expect(ics.to_xml).to include("<text>Custom override text</text>")
        expect(ics.to_xml).not_to include("Cereals")
      end

      it "preserves explicit text through Ext round-trip" do
        ext = Relaton::Bib::Ext.from_xml(
          "<ext><ics><code>67.060</code><text>Custom</text></ics></ext>",
        )
        expect(ext.to_xml).to include("<text>Custom</text>")
        expect(ext.to_xml).not_to include("Cereals")
      end
    end

    context "invalid ICS code" do
      it "does not emit <text>" do
        ics = Relaton::Bib::ICS.new(code: "not-a-real-code")
        expect(ics.to_xml).not_to include("<text>")
      end
    end
  end
end
