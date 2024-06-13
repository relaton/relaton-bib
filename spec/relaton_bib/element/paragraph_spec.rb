describe RelatonBib::Element::Paragraph do
  subject do
    content = RelatonBib::Element::Text.new("text")
    note = RelatonBib::Element::Note.new(content: [content], id: "id-3")
    described_class.new(content: [content], id: "id-1", align: "left", note: [note])
  end

  context "initialize paragraph" do
    it do
      expect(subject.content[0]).to be_instance_of RelatonBib::Element::Text
      expect(subject.id).to eq "id-1"
      expect(subject.align).to eq "left"
      expect(subject.note[0]).to be_instance_of RelatonBib::Element::Note
    end

    it "warn invalid alignment" do
      expect { described_class.new(content: [], id: "id-1", align: "invalid") }
        .to output(/Invalid alignment: `invalid`/).to_stderr_from_any_process
    end
  end

  it "to xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <p id="id-1" align="left">text<note id="id-3">text</note></p>
    XML
  end
end
