describe RelatonBib::Element::PureTextElement do
  it "parse" do
    xml = <<~XML
      Text
      <em>Em</em>
      <strong>Strong</strong>
      <sub>Sub</sub>
      <sup>Sup</sup>
      <tt>Tt</tt>
      <underline style="solid">Underline</underline>
      <strike>Strike</strike>
      <smallcap>Smallcap</smallcap>
      <br/>
    XML
    elements = described_class.parse xml
    expect(elements.size).to eq 10
    expect(elements[0]).to be_instance_of RelatonBib::Element::Text
    expect(elements[1]).to be_instance_of RelatonBib::Element::Em
    expect(elements[2]).to be_instance_of RelatonBib::Element::Strong
    expect(elements[3]).to be_instance_of RelatonBib::Element::Sub
    expect(elements[4]).to be_instance_of RelatonBib::Element::Sup
    expect(elements[5]).to be_instance_of RelatonBib::Element::Tt
    expect(elements[6]).to be_instance_of RelatonBib::Element::Underline
    expect(elements[7]).to be_instance_of RelatonBib::Element::Strike
    expect(elements[8]).to be_instance_of RelatonBib::Element::Smallcap
  end
end
