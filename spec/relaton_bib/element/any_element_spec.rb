describe RelatonBib::Element::AnyElement do
  subject do
    content = RelatonBib::Element::Text.new("text")
    attrs = { type: "type" }
    RelatonBib::Element::AnyElement.new("elm", [content], **attrs)
  end

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <elm type="type">text</elm>
    XML
  end

  it "to_s" do
    expect(subject.to_s).to eq "<elm type=\"type\">text</elm>"
  end
end
