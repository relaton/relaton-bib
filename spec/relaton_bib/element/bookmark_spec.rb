describe RelatonBib::Element::Bookmark do
  subject { RelatonBib::Element::Bookmark.new "id" }

  it "returns content" do
    expect(subject.id).to eq "id"
  end

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <bookmark id="id"/>
    XML
  end
end
