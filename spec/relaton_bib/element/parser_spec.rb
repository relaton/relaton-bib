describe RelatonBib::Element::Parser do
  it "#parse_text_elements" do
    expect(described_class).to receive(:parse_text_element)
      .with(kind_of(Nokogiri::XML::Text)).and_call_original
    text_elements = RelatonBib::Element.parse_text_elements("text")
    expect(text_elements).to be_instance_of Array
    expect(text_elements.size).to eq 1
    expect(text_elements[0]).to be_instance_of RelatonBib::Element::Text
    expect(text_elements[0].content).to eq "text"
  end

  it "#parse_pure_text_elements" do
    expect(described_class).to receive(:parse_pure_text_element)
      .with(kind_of(Nokogiri::XML::Text)).and_call_original
    text_elements = RelatonBib::Element.parse_pure_text_elements("text")
    expect(text_elements).to be_instance_of Array
    expect(text_elements.size).to eq 1
    expect(text_elements[0]).to be_instance_of RelatonBib::Element::Text
    expect(text_elements[0].content).to eq "text"
  end

  it "#parse_children" do
    node = Nokogiri::XML.fragment("<a>text</a>")
    expect(described_class.parse_children(node, &:text)).to eq ["text"]
  end

  context "#parse_text_element" do
    it "with text" do
      node = Nokogiri::XML.fragment("text").children.first
      text = described_class.parse_text_element(node)
      expect(text).to be_instance_of RelatonBib::Element::Text
      expect(text.content).to eq "text"
    end

    it "with stem" do
      node = Nokogiri::XML.fragment("<stem type='MathML'>Text</stem>").children.first
      em = described_class.parse_text_element(node)
      expect(em).to be_instance_of RelatonBib::Element::Stem
    end
  end

  context "#parse_pure_text_element" do
    it "with text" do
      node = Nokogiri::XML.fragment("text").children.first
      text = described_class.parse_pure_text_element(node)
      expect(text).to be_instance_of RelatonBib::Element::Text
      expect(text.content).to eq "text"
    end

    it "with em" do
      node = Nokogiri::XML.fragment("<em>Text</em>").children.first
      em = described_class.parse_pure_text_element(node)
      expect(em).to be_instance_of RelatonBib::Element::Em
    end
  end

  context "#parse_em" do
    it "with text" do
      node = Nokogiri::XML.fragment("<em>Text</em>").children.first
      em = described_class.parse_em(node)
      expect(em).to be_instance_of RelatonBib::Element::Em
      expect(em.content[0]).to be_instance_of RelatonBib::Element::Text
      expect(em.content[0].content).to eq "Text"
    end

    it "with stem" do
      node = Nokogiri::XML.fragment("<em><stem type='MathML'>Text</stem></em>").children.first
      em = described_class.parse_em(node)
      expect(em).to be_instance_of RelatonBib::Element::Em
      expect(em.content[0]).to be_instance_of RelatonBib::Element::Stem
    end
  end

  it "#parse_eref" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <eref normative="true" citeas="cite" type="inline" alt="Alt" bibitemid="ID">
        <locality type="section">
          <referenceFrom>"1"</referenceFrom>
        </locality>
        <localityStack>
          <locality type="section">
            <referenceFrom>"2"</referenceFrom>
          </locality>
        </localityStack>
        <date>2000-01-01</date>text</eref>
    XML
    eref = described_class.parse_eref(node)
    expect(eref).to be_instance_of RelatonBib::Element::Eref
    expect(eref.normative).to eq "true"
    expect(eref.citeas).to eq "cite"
    expect(eref.type).to eq "inline"
    expect(eref.alt).to eq "Alt"
    expect(eref.citation_type).to be_instance_of RelatonBib::Element::CitationType
    expect(eref.citation_type.bibitemid).to eq "ID"
    expect(eref.citation_type.locality).to be_instance_of Array
    expect(eref.citation_type.locality.size).to eq 2
    expect(eref.citation_type.locality[0]).to be_instance_of RelatonBib::Locality
    expect(eref.citation_type.locality[1]).to be_instance_of RelatonBib::LocalityStack
    expect(eref.citation_type.date).to eq "2000-01-01"
    expect(eref.content).to be_instance_of Array
    expect(eref.content.size).to eq 1
    expect(eref.content[0]).to be_instance_of RelatonBib::Element::Text
    expect(eref.content[0].content).to eq "text"
  end

  it "#parse_strong" do
    node = Nokogiri::XML.fragment("<strong>Text</strong>").children.first
    strong = described_class.parse_strong(node)
    expect(strong).to be_instance_of RelatonBib::Element::Strong
    expect(strong.content[0]).to be_instance_of RelatonBib::Element::Text
    expect(strong.content[0].content).to eq "Text"
  end

  it "#parse_stem" do
    node = Nokogiri::XML.fragment("<stem type='MathML'>Text</stem>").children.first
    stem = described_class.parse_stem(node)
    expect(stem).to be_instance_of RelatonBib::Element::Stem
    expect(stem.content).to be_instance_of Array
    expect(stem.content.size).to eq 1
    expect(stem.content[0]).to be_instance_of RelatonBib::Element::Text
    expect(stem.type).to eq "MathML"
  end

  it "#parse_any_elements" do
    node = Nokogiri::XML.fragment("<p id='1'><a href='/path'>text</a></p>").children.first
    elms = described_class.parse_any_elements(node)
    expect(elms).to be_instance_of Array
    expect(elms.size).to eq 1
    expect(elms[0]).to be_instance_of RelatonBib::Element::AnyElement
    expect(elms[0].name).to eq "a"
    expect(elms[0].content).to be_instance_of Array
    expect(elms[0].content.size).to eq 1
    expect(elms[0].content[0]).to be_instance_of RelatonBib::Element::Text
    expect(elms[0].content[0].content).to eq "text"
  end

  it "#parse_sub" do
    node = Nokogiri::XML.fragment("<sub>Text</sub>").children.first
    sub = described_class.parse_sub(node)
    expect(sub).to be_instance_of RelatonBib::Element::Sub
    expect(sub.content[0]).to be_instance_of RelatonBib::Element::Text
    expect(sub.content[0].content).to eq "Text"
  end

  it "#parse_sup" do
    node = Nokogiri::XML.fragment("<sup>Text</sup>").children.first
    sup = described_class.parse_sup(node)
    expect(sup).to be_instance_of RelatonBib::Element::Sup
    expect(sup.content[0]).to be_instance_of RelatonBib::Element::Text
    expect(sup.content[0].content).to eq "Text"
  end

  it "#parse_tt" do
    node = Nokogiri::XML.fragment("<tt>Text</tt>").children.first
    tt = described_class.parse_tt(node)
    expect(tt).to be_instance_of RelatonBib::Element::Tt
    expect(tt.content[0]).to be_instance_of RelatonBib::Element::Text
    expect(tt.content[0].content).to eq "Text"
  end

  context "#parse_tt_element" do
    it "with text" do
      node = Nokogiri::XML.fragment("text").children.first
      tt = described_class.parse_tt_element(node)
      expect(tt).to be_instance_of RelatonBib::Element::Text
    end

    it "with eref" do
      node = Nokogiri::XML.fragment("<eref>Text</eref>").children.first
      tt = described_class.parse_tt_element(node)
      expect(tt).to be_instance_of RelatonBib::Element::Eref
    end
  end

  it "#parse_underline" do
    node = Nokogiri::XML.fragment("<underline style='solid'>Text</underline>").children.first
    underline = described_class.parse_underline(node)
    expect(underline).to be_instance_of RelatonBib::Element::Underline
    expect(underline.content).to be_instance_of Array
    expect(underline.content.size).to eq 1
    expect(underline.content[0]).to be_instance_of RelatonBib::Element::Text
    expect(underline.style).to eq "solid"
  end

  it "#parse_keyword" do
    node = Nokogiri::XML.fragment("<keyword>Text</keyword>").children.first
    keyword = described_class.parse_keyword(node)
    expect(keyword).to be_instance_of RelatonBib::Element::Keyword
    expect(keyword.content[0]).to be_instance_of RelatonBib::Element::Text
  end

  context "#parse_keyword_element" do
    it "with text" do
      node = Nokogiri::XML.fragment("text").children.first
      keyword = described_class.parse_keyword_element(node)
      expect(keyword).to be_instance_of RelatonBib::Element::Text
    end

    it "with index" do
      node = Nokogiri::XML.fragment("<index><primary>Text</primary></index>").children.first
      keyword = described_class.parse_keyword_element(node)
      expect(keyword).to be_instance_of RelatonBib::Element::Index
    end
  end

  context "#parse_ruby" do
    it "with text & pronunciation" do
      node = Nokogiri::XML.fragment(<<~XML).children.first
        <ruby pronunciation="prn" script="Latn" lang="en">Text</ruby>
      XML
      ruby = described_class.parse_ruby(node)
      expect(ruby).to be_instance_of RelatonBib::Element::Ruby
      expect(ruby.content).to be_instance_of RelatonBib::Element::Text
      expect(ruby.annotation.value).to eq "prn"
      expect(ruby.annotation.script).to eq "Latn"
      expect(ruby.annotation.lang).to eq "en"
    end

    it "with ruby & annotation" do
      node = Nokogiri::XML.fragment("<ruby annotation='ant'><ruby>Text</ruby></ruby>").children.first
      ruby = described_class.parse_ruby(node)
      expect(ruby).to be_instance_of RelatonBib::Element::Ruby
      expect(ruby.content).to be_instance_of RelatonBib::Element::Ruby
      expect(ruby.annotation.value).to eq "ant"
    end
  end

  it "#parse_strike" do
    node = Nokogiri::XML.fragment("<strike>Text</strike>").children.first
    strike = described_class.parse_strike(node)
    expect(strike).to be_instance_of RelatonBib::Element::Strike
  end

  it "#parse_smallcap" do
    node = Nokogiri::XML.fragment("<smallcap>Text</smallcap>").children.first
    smallcap = described_class.parse_smallcap(node)
    expect(smallcap).to be_instance_of RelatonBib::Element::Smallcap
  end

  it "#parse_xref" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <xref target="ISO 123" type="inline" alt="Alt">Text</xref>
    XML
    xref = described_class.parse_xref(node)
    expect(xref).to be_instance_of RelatonBib::Element::Xref
    expect(xref.content[0]).to be_instance_of RelatonBib::Element::Text
    expect(xref.target).to eq "ISO 123"
    expect(xref.type).to eq "inline"
    expect(xref.alt).to eq "Alt"
  end

  it "#parse_br" do
    node = Nokogiri::XML.fragment("<br>").children.first
    br = described_class.parse_br(node)
    expect(br).to be_instance_of RelatonBib::Element::Br
  end

  it "#parse_link" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <link target="http://example.com" type="inline" alt="Alt">Text</link>
    XML
    link = described_class.parse_link(node)
    expect(link).to be_instance_of RelatonBib::Element::Hyperlink
    expect(link.content[0]).to be_instance_of RelatonBib::Element::Text
    expect(link.target).to eq "http://example.com"
    expect(link.type).to eq "inline"
    expect(link.alt).to eq "Alt"
  end

  it "#parse_hr" do
    node = Nokogiri::XML.fragment("<hr>").children.first
    hr = described_class.parse_hr(node)
    expect(hr).to be_instance_of RelatonBib::Element::Hr
  end

  it "#parse_pagebreak" do
    node = Nokogiri::XML.fragment("<pagebreak>").children.first
    pagebreak = described_class.parse_pagebreak(node)
    expect(pagebreak).to be_instance_of RelatonBib::Element::PageBreak
  end

  it "#parse_bookmark" do
    node = Nokogiri::XML.fragment("<bookmark id='1'>").children.first
    bookmark = described_class.parse_bookmark(node)
    expect(bookmark).to be_instance_of RelatonBib::Element::Bookmark
    expect(bookmark.id).to eq "1"
  end

  it "#parse_image" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <image id="ID" src="/image.png" mimetype="image/png" filename="image.png" width="4" height="5" alt="Alt" title="Title">
    XML
    image = described_class.parse_image(node)
    expect(image).to be_instance_of RelatonBib::Element::Image
    expect(image.src).to eq "/image.png"
    expect(image.mimetype).to eq "image/png"
    expect(image.filename).to eq "image.png"
    expect(image.width).to eq "4"
    expect(image.height).to eq "5"
    expect(image.alt).to eq "Alt"
    expect(image.title).to eq "Title"
  end

  it "#parse_index" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <index to="to">
        <primary>Primary</primary>
        <secondary>Secondary</secondary>
        <tertiary>Tertiary</tertiary>
      </index>
    XML
    index = described_class.parse_index(node)
    expect(index).to be_instance_of RelatonBib::Element::Index
    expect(index.primary[0]).to be_instance_of RelatonBib::Element::Text
    expect(index.primary[0].content).to eq "Primary"
    expect(index.secondary[0]).to be_instance_of RelatonBib::Element::Text
    expect(index.secondary[0].content).to eq "Secondary"
    expect(index.tertiary[0]).to be_instance_of RelatonBib::Element::Text
    expect(index.tertiary[0].content).to eq "Tertiary"
    expect(index.to).to eq "to"
  end

  it "#parse_index_xref" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <index-xref also="also">
        <primary>Primary</primary>
        <secondary>Secondary</secondary>
        <tertiary>Tertiary</tertiary>
        <target>Target</target>
      </index-xref>
    XML
    index_xref = described_class.parse_index_xref(node)
    expect(index_xref).to be_instance_of RelatonBib::Element::IndexXref
    expect(index_xref.primary[0]).to be_instance_of RelatonBib::Element::Text
    expect(index_xref.primary[0].content).to eq "Primary"
    expect(index_xref.secondary[0]).to be_instance_of RelatonBib::Element::Text
    expect(index_xref.secondary[0].content).to eq "Secondary"
    expect(index_xref.tertiary[0]).to be_instance_of RelatonBib::Element::Text
    expect(index_xref.tertiary[0].content).to eq "Tertiary"
    expect(index_xref.target[0]).to be_instance_of RelatonBib::Element::Text
    expect(index_xref.target[0].content).to eq "Target"
    expect(index_xref.also).to eq "also"
  end
end
