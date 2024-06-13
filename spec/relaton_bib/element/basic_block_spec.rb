describe RelatonBib::Element::BasicBlock do
  it "parse elements" do
    xml = <<~XML
      <p>Text</p>
      <table id="ID"><tbody><tr><td>cell</td></tr></tbody></table>
      <formula id="ID"><stem type="MathML">Stem</stem></formula>
      <admonition id="ID" type="note"><p>Text</p></admonition>
      <ol><li>Item</li></ol>
      <ul><li>Item</li></ul>
      <dl><dt>Term</dt><dd>Definition</dd></dl>
      <figure id='ID'><p>Text</p></figure>
      <quote id='ID'><p>Text</p></quote>
      <sourcecode id='ID'>code</sourcecode>
      <example id='ID'><p>Text</p></example>
      <review id="ID" reviewer="Reviewer"><p id="pID">Text</p></review>
      <pre id='ID'>Text</pre>
      <note id='ID'><p id='pID'>Text</p></note>
      <pagebreak/>
      <hr/>
      <bookmark id='ID'/>
      <amend change='add'/>
    XML
    elements = described_class.parse xml
    expect(elements.size).to eq 18
    expect(elements[0]).to be_instance_of RelatonBib::Element::ParagraphWithFootnote
    expect(elements[1]).to be_instance_of RelatonBib::Element::Table
    expect(elements[2]).to be_instance_of RelatonBib::Element::Formula
    expect(elements[3]).to be_instance_of RelatonBib::Element::Admonition
    expect(elements[4]).to be_instance_of RelatonBib::Element::Ol
    expect(elements[5]).to be_instance_of RelatonBib::Element::Ul
    expect(elements[6]).to be_instance_of RelatonBib::Element::Dl
    expect(elements[7]).to be_instance_of RelatonBib::Element::Figure
    expect(elements[8]).to be_instance_of RelatonBib::Element::Quote
    expect(elements[9]).to be_instance_of RelatonBib::Element::Sourcecode
    expect(elements[10]).to be_instance_of RelatonBib::Element::Example
    expect(elements[11]).to be_instance_of RelatonBib::Element::Review
    expect(elements[12]).to be_instance_of RelatonBib::Element::Pre
    expect(elements[13]).to be_instance_of RelatonBib::Element::Note
    expect(elements[14]).to be_instance_of RelatonBib::Element::PageBreak
    expect(elements[15]).to be_instance_of RelatonBib::Element::Hr
    expect(elements[16]).to be_instance_of RelatonBib::Element::Bookmark
    expect(elements[17]).to be_instance_of RelatonBib::Element::Amend
  end

  it "wraps text in p" do
    elements = described_class.parse("<em>Em</em>Text1<br/><p>Text2</p>")
    expect(elements).to be_instance_of Array
    expect(elements.size).to eq 2
    expect(elements[0]).to be_instance_of RelatonBib::Element::ParagraphWithFootnote
    expect(elements[0].to_s).to eq "<p><em>Em</em>Text1</p>"
    expect(elements[1]).to be_instance_of RelatonBib::Element::ParagraphWithFootnote
    expect(elements[1].to_s).to eq "<p>Text2</p>"
  end

  it "return empty array if no BasicBlock elements" do
    elements = RelatonBib::Element::BasicBlock.parse("text")
    expect(elements).to be_empty
  end
end
