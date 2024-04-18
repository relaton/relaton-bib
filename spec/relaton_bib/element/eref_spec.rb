describe RelatonBib::Element::Eref do
  let(:content) { RelatonBib::Element::Text.new "content" }
  let(:citation_type) do
    locality = RelatonBib::Locality.new("section", "1")
    RelatonBib::Element::CitationType.new "ISO 123", locality: [locality]
  end
  subject do
    RelatonBib::Element::Eref.new(
      [content], citeas: "citeas", type: "type", citation_type: citation_type
    )
  end

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <eref citeas="citeas" type="type" bibitemid="ISO 123">
        <locality type="section"><referenceFrom>1</referenceFrom></locality>
        content
      </eref>
    XML
  end

  it "to_s" do
    expect(subject.to_s).to eq(
      "<eref citeas=\"citeas\" type=\"type\" bibitemid=\"ISO 123\"><locality type=\"section\">" \
      "<referenceFrom>1</referenceFrom></locality>content</eref>"
    )
  end
end
