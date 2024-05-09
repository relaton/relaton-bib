describe RelatonBib::Element::TextElement do
  it "parse" do
    xml = <<~XML
      Text
      <em>Em</em>
      <eref citeas="SiteAs" type="inline" bibitemid="123">Eref</eref>
      <strong>Strong</strong>
      <stem type="MathML">Stem</stem>
      <sub>Sub</sub>
      <sup>Sup</sup>
      <tt>Tt</tt>
      <underline style="solid">Underline</underline>
      <keyword>Keyword</keyword>
      <ruby pronunciation="prn" script="Latn" lang="en">Ruby</ruby>
      <strike>Strike</strike>
      <smallcap>Smallcap</smallcap>
      <xref target="ISO 123" type="inline" alt="Alt">Xref</xref>
      <br/>
      <link target="http://example.com" type="inline" alt="Alt">Link</link>
      <hr/>
      <pagebreak/>
      <bookmark id="ID"/>
      <image id="ID" src="/image.png" mimetype="image/png" filename="image.png" width="4" height="5" alt="Alt" title="Title"/>
      <index><primary>Primary</primary></index>
      <index-xref also="also"><primary>Primary</primary><target>Target</target></index-xref>
    XML
    elements = described_class.parse xml
    expect(elements.size).to eq 22
    expect(elements[0]).to be_instance_of RelatonBib::Element::Text
    expect(elements[1]).to be_instance_of RelatonBib::Element::Em
    expect(elements[2]).to be_instance_of RelatonBib::Element::Eref
    expect(elements[3]).to be_instance_of RelatonBib::Element::Strong
    expect(elements[4]).to be_instance_of RelatonBib::Element::Stem
    expect(elements[5]).to be_instance_of RelatonBib::Element::Sub
    expect(elements[6]).to be_instance_of RelatonBib::Element::Sup
    expect(elements[7]).to be_instance_of RelatonBib::Element::Tt
    expect(elements[8]).to be_instance_of RelatonBib::Element::Underline
    expect(elements[9]).to be_instance_of RelatonBib::Element::Keyword
    expect(elements[10]).to be_instance_of RelatonBib::Element::Ruby
    expect(elements[11]).to be_instance_of RelatonBib::Element::Strike
    expect(elements[12]).to be_instance_of RelatonBib::Element::Smallcap
    expect(elements[13]).to be_instance_of RelatonBib::Element::Xref
    expect(elements[14]).to be_instance_of RelatonBib::Element::Br
    expect(elements[15]).to be_instance_of RelatonBib::Element::Hyperlink
    expect(elements[16]).to be_instance_of RelatonBib::Element::Hr
    expect(elements[17]).to be_instance_of RelatonBib::Element::PageBreak
    expect(elements[18]).to be_instance_of RelatonBib::Element::Bookmark
    expect(elements[19]).to be_instance_of RelatonBib::Element::Image
    expect(elements[20]).to be_instance_of RelatonBib::Element::Index
    expect(elements[21]).to be_instance_of RelatonBib::Element::IndexXref
  end
end
