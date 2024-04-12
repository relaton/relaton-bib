describe RelatonBib::Element::Parser do
  it "parse text elements" do
    expect(described_class).to receive(:parse_text_element)
      .with(kind_of(Nokogiri::XML::Text)).and_call_original
    text_elements = RelatonBib::Element.parse_text_elements("text")
    expect(text_elements).to be_instance_of Array
    expect(text_elements.size).to eq 1
    expect(text_elements[0]).to be_instance_of RelatonBib::Element::Text
    expect(text_elements[0].content).to eq "text"
  end

  it "parse pure text elements" do
    expect(described_class).to receive(:parse_pure_text_element)
      .with(kind_of(Nokogiri::XML::Text)).and_call_original
    text_elements = RelatonBib::Element.parse_pure_text_elements("text")
    expect(text_elements).to be_instance_of Array
    expect(text_elements.size).to eq 1
    expect(text_elements[0]).to be_instance_of RelatonBib::Element::Text
    expect(text_elements[0].content).to eq "text"
  end

  it "parse children" do
    node = Nokogiri::XML.fragment("<a>text</a>")
    expect(described_class.parse_children(node, &:text)).to eq ["text"]
  end

  context "parse text element" do
  end
  # it "em" do
  #   xml = <<~XML
  #     <em>
  #       <eref normative="true" citeas="cite" type="inline" alt="Alt" bibitemid="ID">
  #         <locality type="section">
  #           <referenceFrom>"1"</referenceFrom>
  #           <referenceTo>"2"</referenceTo>
  #         </locality>
  #         <date>2000-01-01</date>
  #         text
  #       </eref>
  #       <strong>text</strong>
  #     </em>
  #   XML
  #   node = Nokogiri::XML.fragment(xml).children.first
  #   em = described_class.parse_text_element(node)
  #   expect(em.to_string).to be_equivalent_to xml
  #   # expect(em).to be_instance_of RelatonBib::Element::Em
  #   # expect(em.content).to be_instance_of Array
  #   # expect(em.content.size).to eq 1
  #   # expect(em.content[0]).to be_instance_of RelatonBib::Element::Text
  #   # expect(em.content[0].content).to eq "text"
  # end

  it "strong" do
    node = Nokogiri::XML.fragment("<strong>text</strong>").children.first
    strong = described_class.parse_text_element(node)
    expect(strong).to be_instance_of RelatonBib::Element::Strong
  end

  it "eref" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <eref normative="true" citeas="cite" type="inline" alt="Alt" bibitemid="ID">
        <locality type="section">
          <referenceFrom>"1"</referenceFrom>
          <referenceTo>"2"</referenceTo>
        </locality>
        <date>2000-01-01</date>
        text
      </eref>
    XML
    eref = described_class.parse_text_element(node)
    expect(eref).to be_instance_of RelatonBib::Element::Eref
  end
end
