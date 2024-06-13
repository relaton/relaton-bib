describe RelatonBib::Element::Th do
  subject do
    content = RelatonBib::Element::Text.new("Text")
    RelatonBib::Element::Th.new(
      colspan: "2", rowspan: "3", align: "center", valign: "top", content: [content]
    )
  end

  context "initialize th element" do
    it do
      expect(subject.content[0]).to be_instance_of RelatonBib::Element::Text
      expect(subject.colspan).to eq "2"
      expect(subject.rowspan).to eq "3"
      expect(subject.align).to eq "center"
      expect(subject.valign).to eq "top"
    end

    it "warn invalid alignment" do
      expect { described_class.new content: [], align: "invalid" }
        .to output(/Invalid alignment: `invalid`/).to_stderr_from_any_process
    end

    it "warn invalid valignment" do
      expect { described_class.new content: [], valign: "invalid" }
        .to output(/Invalid alignment: `invalid`/).to_stderr_from_any_process
    end
  end

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <th colspan="2" rowspan="3" align="center" valign="top">Text</th>
    XML
  end
end
