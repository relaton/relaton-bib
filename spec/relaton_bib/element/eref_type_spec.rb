describe RelatonBib::Element::ErefType do
  let(:content) { RelatonBib::Element::Text.new "text" }
  let(:citeas) { "citeas" }
  let(:type) { "external" }
  let(:citation_type) do
    locality = RelatonBib::Locality.new("section", "1", "2")
    RelatonBib::Element::CitationType.new "ISO 123", locality: [locality], date: "2001-02-03"
  end
  let(:args) { { normative: "normative", alt: "alt" } }

  subject do
    described_class.new(
      content: [content], citeas: citeas, type: type, citation_type: citation_type, **args,
    )
  end

  context "initialize" do
    it do
      expect(subject.content[0]).to be_instance_of RelatonBib::Element::Text
      expect(subject.citeas).to eq "citeas"
      expect(subject.type).to eq "external"
      expect(subject.citation_type).to eq citation_type
      expect(subject.normative).to eq "normative"
      expect(subject.alt).to eq "alt"
    end

    context "with invalid type" do
      let(:type) { "invalid" }
      it "warn" do
        expect do
          subject
        end.to output(/invalid eref type: `invalid`/).to_stderr_from_any_process
      end
    end
  end

  context "to_xml" do
    context "with normative and alt" do
      it do
        xml = Nokogiri::XML::Builder.new { eref { |b| subject.to_xml(b) } }.doc.root
        expect(xml.to_xml).to be_equivalent_to <<~XML
          <eref normative="normative" citeas="citeas" type="external" alt="alt" bibitemid="ISO 123">
            <locality type="section">
              <referenceFrom>1</referenceFrom>
              <referenceTo>2</referenceTo>
            </locality>
            <date>2001-02-03</date>
            text
          </eref>
        XML
      end
    end
  end
end
