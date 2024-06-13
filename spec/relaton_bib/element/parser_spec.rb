describe RelatonBib::Element::Parser do
  context "::content_to_node" do
    it "with text" do
      node = RelatonBib::Element::Parser.content_to_node("text")
      expect(node).to be_instance_of Nokogiri::XML::DocumentFragment
    end

    it "with nokogiri node" do
      node = Nokogiri::XML.fragment("<a>text</a>").children.first
      expect(RelatonBib::Element::Parser.content_to_node(node)).to be node
    end
  end

  it "::parse_children" do
    node = Nokogiri::XML.fragment("<p>text<a>ref</a></p>").children.first
    expect(described_class.parse_children(node, &:to_xml)).to eq ["text", "<a>ref</a>"]
  end

  it "::parse_node" do
    node = Nokogiri::XML.fragment("<p>text</p>").children.first
    expect(described_class).to receive(:parse_p).with(node).and_return(:p)
    expect(described_class.parse_node(node)).to eq :p
  end

  shared_examples "elements collection" do |xml, klass|
    it do
      node = Nokogiri::XML.fragment(xml).children.first
      element = described_class.send(collection_method, node)
      expect(element).to be_instance_of klass
    end
  end

  it "::parse_em" do
    node = Nokogiri::XML.fragment("<em>Text</em>").children.first
    em = described_class.parse_em(node)
    expect(em).to be_instance_of RelatonBib::Element::Em
    expect(em.content.size).to eq 1
    expect(em.content[0]).to be_instance_of RelatonBib::Element::Text
    expect(em.content[0].content).to eq "Text"
  end

  context "::parse_em_element" do
    let(:collection_method) { :parse_em_element }
    it_behaves_like "elements collection", "Text", RelatonBib::Element::Text
    it_behaves_like "elements collection", "<stem type='MathML'>Text</stem>", RelatonBib::Element::Stem
    it_behaves_like "elements collection", <<~XML, RelatonBib::Element::Eref
      <eref citeas="SiteAs" type="inline" bibitemid="123">Eref</eref>
    XML
    it_behaves_like "elements collection", "<xref target='ISO 123' type='inline'>Xref</xref>", RelatonBib::Element::Xref
    it_behaves_like "elements collection", <<~XML, RelatonBib::Element::Hyperlink
      <link target="http://example.com" type="inline">Link</link>
    XML
    it_behaves_like "elements collection", "<index><primary>Primary</primary></index>", RelatonBib::Element::Index
    it_behaves_like "elements collection", <<~XML, RelatonBib::Element::IndexXref
      <index-xref><primary>Primary</primary></index-xref>
    XML
  end

  it "::parse_eref" do
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

  it "::parse_strong" do
    node = Nokogiri::XML.fragment("<strong>Text</strong>").children.first
    strong = described_class.parse_strong(node)
    expect(strong).to be_instance_of RelatonBib::Element::Strong
    expect(strong.content.size).to eq 1
    expect(strong.content[0]).to be_instance_of RelatonBib::Element::Text
    expect(strong.content[0].content).to eq "Text"
  end

  it "::parse_stem" do
    node = Nokogiri::XML.fragment("<stem type='MathML'>Text</stem>").children.first
    stem = described_class.parse_stem(node)
    expect(stem).to be_instance_of RelatonBib::Element::Stem
    expect(stem.content).to be_instance_of Array
    expect(stem.content.size).to eq 1
    expect(stem.content[0]).to be_instance_of RelatonBib::Element::Text
    expect(stem.type).to eq "MathML"
  end

  it "::parse_any_elements" do
    node = Nokogiri::XML.fragment("<p id='1'><a href='/path'>text</a></p>").children.first
    elms = described_class.parse_any_elements(node)
    expect(elms).to be_instance_of Array
    expect(elms.size).to eq 1
    expect(elms[0]).to be_instance_of RelatonBib::Element::AnyElement
    expect(elms[0].name).to eq "a"
    expect(elms[0].content).to be_instance_of Array
    expect(elms[0].content.size).to eq 1
    expect(elms[0].content.size).to eq 1
    expect(elms[0].content[0]).to be_instance_of RelatonBib::Element::Text
    expect(elms[0].content[0].content).to eq "text"
  end

  it "::parse_sub" do
    node = Nokogiri::XML.fragment("<sub>Text</sub>").children.first
    sub = described_class.parse_sub(node)
    expect(sub).to be_instance_of RelatonBib::Element::Sub
    expect(sub.content.size).to eq 1
    expect(sub.content[0]).to be_instance_of RelatonBib::Element::Text
    expect(sub.content[0].content).to eq "Text"
  end

  it "::parse_sup" do
    node = Nokogiri::XML.fragment("<sup>Text</sup>").children.first
    sup = described_class.parse_sup(node)
    expect(sup).to be_instance_of RelatonBib::Element::Sup
    expect(sup.content.size).to eq 1
    expect(sup.content[0]).to be_instance_of RelatonBib::Element::Text
    expect(sup.content[0].content).to eq "Text"
  end

  it "::parse_tt" do
    node = Nokogiri::XML.fragment("<tt>Text</tt>").children.first
    tt = described_class.parse_tt(node)
    expect(tt).to be_instance_of RelatonBib::Element::Tt
    expect(tt.content.size).to eq 1
    expect(tt.content[0]).to be_instance_of RelatonBib::Element::Text
    expect(tt.content[0].content).to eq "Text"
  end

  context "::parse_tt_element" do
    let(:collection_method) { :parse_tt_element }
    it_behaves_like "elements collection", "Text", RelatonBib::Element::Text
    it_behaves_like "elements collection", <<~XML, RelatonBib::Element::Eref
      <eref citeas="SiteAs" type="inline" bibitemid="123">Eref</eref>
    XML
    it_behaves_like "elements collection", "<xref target='ISO 123' type='inline'>Xref</xref>", RelatonBib::Element::Xref
    it_behaves_like "elements collection", <<~XML, RelatonBib::Element::Hyperlink
      <link target="http://example.com" type="inline">Link</link>
    XML
    it_behaves_like "elements collection", "<index><primary>Primary</primary></index>", RelatonBib::Element::Index
    it_behaves_like "elements collection", <<~XML, RelatonBib::Element::IndexXref
      <index-xref><primary>Primary</primary></index-xref>
    XML
  end

  it "::parse_underline" do
    node = Nokogiri::XML.fragment("<underline style='solid'>Text</underline>").children.first
    underline = described_class.parse_underline(node)
    expect(underline).to be_instance_of RelatonBib::Element::Underline
    expect(underline.content).to be_instance_of Array
    expect(underline.content.size).to eq 1
    expect(underline.content[0]).to be_instance_of RelatonBib::Element::Text
    expect(underline.style).to eq "solid"
  end

  it "::parse_keyword" do
    node = Nokogiri::XML.fragment("<keyword>Text</keyword>").children.first
    keyword = described_class.parse_keyword(node)
    expect(keyword).to be_instance_of RelatonBib::Element::Keyword
    expect(keyword.content.size).to eq 1
    expect(keyword.content[0]).to be_instance_of RelatonBib::Element::Text
  end

  context "::parse_keyword_element" do
    let(:collection_method) { :parse_keyword_element }
    it_behaves_like "elements collection", "Text", RelatonBib::Element::Text
    it_behaves_like "elements collection", "<index><primary>Primary</primary></index>", RelatonBib::Element::Index
    it_behaves_like "elements collection", <<~XML, RelatonBib::Element::IndexXref
      <index-xref><primary>Primary</primary></index-xref>
    XML
  end

  context "::parse_ruby" do
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

  it "::parse_strike" do
    node = Nokogiri::XML.fragment("<strike>Text</strike>").children.first
    strike = described_class.parse_strike(node)
    expect(strike).to be_instance_of RelatonBib::Element::Strike
  end

  it "::parse_smallcap" do
    node = Nokogiri::XML.fragment("<smallcap>Text</smallcap>").children.first
    smallcap = described_class.parse_smallcap(node)
    expect(smallcap).to be_instance_of RelatonBib::Element::Smallcap
  end

  it "::parse_xref" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <xref target="ISO 123" type="inline" alt="Alt">Text</xref>
    XML
    xref = described_class.parse_xref(node)
    expect(xref).to be_instance_of RelatonBib::Element::Xref
    expect(xref.content.size).to eq 1
    expect(xref.content[0]).to be_instance_of RelatonBib::Element::Text
    expect(xref.target).to eq "ISO 123"
    expect(xref.type).to eq "inline"
    expect(xref.alt).to eq "Alt"
  end

  it "::parse_br" do
    node = Nokogiri::XML.fragment("<br>").children.first
    br = described_class.parse_br(node)
    expect(br).to be_instance_of RelatonBib::Element::Br
  end

  it "::parse_link" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <link target="http://example.com" type="inline" alt="Alt">Text</link>
    XML
    link = described_class.parse_link(node)
    expect(link).to be_instance_of RelatonBib::Element::Hyperlink
    expect(link.content.size).to eq 1
    expect(link.content[0]).to be_instance_of RelatonBib::Element::Text
    expect(link.target).to eq "http://example.com"
    expect(link.type).to eq "inline"
    expect(link.alt).to eq "Alt"
  end

  it "::parse_hr" do
    node = Nokogiri::XML.fragment("<hr>").children.first
    hr = described_class.parse_hr(node)
    expect(hr).to be_instance_of RelatonBib::Element::Hr
  end

  it "::parse_pagebreak" do
    node = Nokogiri::XML.fragment("<pagebreak>").children.first
    pagebreak = described_class.parse_pagebreak(node)
    expect(pagebreak).to be_instance_of RelatonBib::Element::PageBreak
  end

  it "::parse_bookmark" do
    node = Nokogiri::XML.fragment("<bookmark id='1'>").children.first
    bookmark = described_class.parse_bookmark(node)
    expect(bookmark).to be_instance_of RelatonBib::Element::Bookmark
    expect(bookmark.id).to eq "1"
  end

  it "::parse_image" do
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

  it "::parse_index" do
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

  it "::parse_index_xref" do
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
    expect(index_xref.primary.size).to eq 1
    expect(index_xref.primary[0]).to be_instance_of RelatonBib::Element::Text
    expect(index_xref.primary[0].content).to eq "Primary"
    expect(index_xref.secondary.size).to eq 1
    expect(index_xref.secondary[0]).to be_instance_of RelatonBib::Element::Text
    expect(index_xref.secondary[0].content).to eq "Secondary"
    expect(index_xref.tertiary.size).to eq 1
    expect(index_xref.tertiary[0]).to be_instance_of RelatonBib::Element::Text
    expect(index_xref.tertiary[0].content).to eq "Tertiary"
    expect(index_xref.target.size).to eq 1
    expect(index_xref.target[0]).to be_instance_of RelatonBib::Element::Text
    expect(index_xref.target[0].content).to eq "Target"
    expect(index_xref.also).to eq "also"
  end

  it "::parse_paragraph" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <p id="ID" align="left">text<note id="nID"><p id="pID">note</p></note></p>
    XML
    paragraph = described_class.parse_paragraph(node)
    expect(paragraph).to be_instance_of RelatonBib::Element::Paragraph
    expect(paragraph.id).to eq "ID"
    expect(paragraph.align).to eq "left"
    expect(paragraph.content.size).to eq 1
    expect(paragraph.content[0]).to be_instance_of RelatonBib::Element::Text
    expect(paragraph.content[0].content).to eq "text"
    expect(paragraph.note.size).to eq 1
    expect(paragraph.note[0]).to be_instance_of RelatonBib::Element::Note
  end

  it "::parse_notes" do
    node = Nokogiri::XML.fragment "<note id='ID'><p id='pID'>text</p></note>"
    notes = described_class.parse_notes node
    expect(notes).to be_instance_of Array
    expect(notes.size).to eq 1
    expect(notes[0]).to be_instance_of RelatonBib::Element::Note
    expect(notes[0].id).to eq "ID"
    expect(notes[0].content.size).to eq 1
    expect(notes[0].content[0]).to be_instance_of RelatonBib::Element::Paragraph
    expect(notes[0].content[0].content[0].content).to eq "text"
  end

  it "::parse_table" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <table id="ID" unnumbered="false" subsequence="SubSec" alt="Alt" summary="Summary" uri="URI">
        <name>Tname</name>
        <thead><tr><th>head</th></tr></thead>
        <tbody><tr><td>cell</td></tr></tbody>
        <tfoot><tr><td>foot</td></tr></tfoot>
        <note><p id="pID">note</p></note>
        <dl><dt>dt</dt></dl>
      </table>
    XML
    table = described_class.parse_table node
    expect(table).to be_instance_of RelatonBib::Element::Table
    expect(table.id).to eq "ID"
    expect(table.unnumbered).to eq false
    expect(table.subsequence).to eq "SubSec"
    expect(table.alt).to eq "Alt"
    expect(table.summary).to eq "Summary"
    expect(table.uri).to eq "URI"
    expect(table.tname).to be_instance_of RelatonBib::Element::Tname
    expect(table.thead).to be_instance_of RelatonBib::Element::Thead
    expect(table.thead.content).to be_instance_of RelatonBib::Element::Tr
    expect(table.tbody).to be_instance_of RelatonBib::Element::Tbody
    expect(table.tbody.content.size).to eq 1
    expect(table.tbody.content[0]).to be_instance_of RelatonBib::Element::Tr
    expect(table.tfoot).to be_instance_of RelatonBib::Element::Tfoot
    expect(table.tfoot.content).to be_instance_of RelatonBib::Element::Tr
    expect(table.note.size).to eq 1
    expect(table.note[0]).to be_instance_of RelatonBib::Element::Table::Note
    expect(table.dl).to be_instance_of RelatonBib::Element::Dl
  end

  it "::parse_tname" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <name>Tname<eref citeas="SiteAs" type="inline" bibitemid="123">Eref</eref>
      <stem type="MathML">Stem</stem><keyword>Keyword</keyword>
      <xref target="Target" type="inline">Xref</xref>
      <link target="http://example.com" type="inline">Link</link>
      <index><primary>Primary</primary></index>
      <index-xref also="true"><primary>Primary</primary><target>idx-ref-target</target></index-xref>
      </name>
    XML
    tname = described_class.parse_tname node
    expect(tname).to be_instance_of RelatonBib::Element::Tname
    expect(tname.content.size).to eq 8
    expect(tname.content[0]).to be_instance_of RelatonBib::Element::Text
    expect(tname.content[1]).to be_instance_of RelatonBib::Element::Eref
    expect(tname.content[2]).to be_instance_of RelatonBib::Element::Stem
    expect(tname.content[3]).to be_instance_of RelatonBib::Element::Keyword
    expect(tname.content[4]).to be_instance_of RelatonBib::Element::Xref
    expect(tname.content[5]).to be_instance_of RelatonBib::Element::Hyperlink
    expect(tname.content[6]).to be_instance_of RelatonBib::Element::Index
    expect(tname.content[7]).to be_instance_of RelatonBib::Element::IndexXref
  end

  it "::parse_tr" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <tr><th>head</th><td>cell</td></tr>
    XML
    tr = described_class.parse_tr node
    expect(tr).to be_instance_of RelatonBib::Element::Tr
    expect(tr.content.size).to eq 2
    expect(tr.content[0]).to be_instance_of RelatonBib::Element::Th
    expect(tr.content[1]).to be_instance_of RelatonBib::Element::Td
  end

  context "::parse_th" do
    it "with text" do
      node = Nokogiri::XML.fragment(<<~XML).children.first
        <th colspan="3" rowspan="2" align="center" valign="top">head</th>
      XML
      th = described_class.parse_th node
      expect(th).to be_instance_of RelatonBib::Element::Th
      expect(th.colspan).to eq "3"
      expect(th.rowspan).to eq "2"
      expect(th.align).to eq "center"
      expect(th.valign).to eq "top"
      expect(th.content.size).to eq 1
      expect(th.content[0]).to be_instance_of RelatonBib::Element::Text
    end

    it "with paragraph" do
      node = Nokogiri::XML.fragment(<<~XML).children.first
        <th><p>head</p></th>
      XML
      th = described_class.parse_th node
      expect(th).to be_instance_of RelatonBib::Element::Th
      expect(th.content.size).to eq 1
      expect(th.content[0]).to be_instance_of RelatonBib::Element::ParagraphWithFootnote
    end
  end

  it "::parse_td" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <td colspan="3" rowspan="2" align="center" valign="top">cell</td>
    XML
    td = described_class.parse_td node
    expect(td).to be_instance_of RelatonBib::Element::Td
    expect(td.colspan).to eq "3"
    expect(td.rowspan).to eq "2"
    expect(td.align).to eq "center"
    expect(td.valign).to eq "top"
    expect(td.content.size).to eq 1
    expect(td.content[0]).to be_instance_of RelatonBib::Element::Text
  end

  it "::parse_dl" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <dl><dt>dt</dt><dd><p>dd</p></dd></dl>
    XML
    dl = described_class.parse_dl node
    expect(dl).to be_instance_of RelatonBib::Element::Dl
    expect(dl.content.size).to eq 2
    expect(dl.content[0]).to be_instance_of RelatonBib::Element::Dt
    expect(dl.content[1]).to be_instance_of RelatonBib::Element::Dd
    expect(dl.content[1].content[0]).to be_instance_of RelatonBib::Element::ParagraphWithFootnote
  end

  it "::parse_p" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <p id="ID" align="left">text<fn reference="ref"><p id="pID">FN</p></fn><note id="nID">note</note></p>
    XML
    p = described_class.parse_p node
    expect(p).to be_instance_of RelatonBib::Element::ParagraphWithFootnote
    expect(p.id).to eq "ID"
    expect(p.align).to eq "left"
    expect(p.content.size).to eq 2
    expect(p.content[0]).to be_instance_of RelatonBib::Element::Text
    expect(p.content[1]).to be_instance_of RelatonBib::Element::Fn
    expect(p.note[0]).to be_instance_of RelatonBib::Element::Note
  end

  it "::parse_formula" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <formula id="ID" unnumbered="false" subsequence="SubSec" inequality="true">
        <stem type="MathML">Stem</stem>
        <dl><dt>dt</dt></dl>
        <note id="nID"><p id="pID">note</p></note>
      </formula>
    XML
    formula = described_class.parse_formula node
    expect(formula).to be_instance_of RelatonBib::Element::Formula
    expect(formula.id).to eq "ID"
    expect(formula.unnumbered).to eq false
    expect(formula.subsequence).to eq "SubSec"
    expect(formula.inequality).to eq true
    expect(formula.stem).to be_instance_of RelatonBib::Element::Stem
    expect(formula.dl).to be_instance_of RelatonBib::Element::Dl
    expect(formula.note.size).to eq 1
    expect(formula.note[0]).to be_instance_of RelatonBib::Element::Note
  end

  it "::parse_admonition" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <admonition type="tip" class="Cls" id="ID" uri="URI">
        <name>Tname</name>
        <p>text</p>
        <note id="nID"><p id="pID">note</p></note>
      </admonition>
    XML
    admonition = described_class.parse_admonition node
    expect(admonition).to be_instance_of RelatonBib::Element::Admonition
    expect(admonition.type).to eq "tip"
    expect(admonition.klass).to eq "Cls"
    expect(admonition.id).to eq "ID"
    expect(admonition.uri).to eq "URI"
    expect(admonition.tname).to be_instance_of RelatonBib::Element::Tname
    expect(admonition.content.size).to eq 1
    expect(admonition.content[0]).to be_instance_of RelatonBib::Element::ParagraphWithFootnote
    expect(admonition.note.size).to eq 1
    expect(admonition.note[0]).to be_instance_of RelatonBib::Element::Note
  end

  it "::parse_ol" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <ol id="ID" type="roman" start="1">
        <li><p>item</p></li>
        <note id="nID"><p id="pID">note</p></note>
      </ol>
    XML
    ol = described_class.parse_ol node
    expect(ol).to be_instance_of RelatonBib::Element::Ol
    expect(ol.id).to eq "ID"
    expect(ol.type).to eq "roman"
    expect(ol.start).to eq "1"
    expect(ol.content.size).to eq 1
    expect(ol.content[0]).to be_instance_of RelatonBib::Element::Li
    expect(ol.note.size).to eq 1
    expect(ol.note[0]).to be_instance_of RelatonBib::Element::Note
  end

  it "::parse_li" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <li id="ID"><p>item</p></li>
    XML
    li = described_class.parse_li node
    expect(li).to be_instance_of RelatonBib::Element::Li
    expect(li.content.size).to eq 1
    expect(li.content[0]).to be_instance_of RelatonBib::Element::ParagraphWithFootnote
  end

  it "::parse_ul" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <ul id="ID">
        <li><p>item</p></li>
        <note id="nID"><p id="pID">note</p></note>
      </ul>
    XML
    ul = described_class.parse_ul node
    expect(ul).to be_instance_of RelatonBib::Element::Ul
    expect(ul.id).to eq "ID"
    expect(ul.content.size).to eq 1
    expect(ul.content[0]).to be_instance_of RelatonBib::Element::Li
    expect(ul.note.size).to eq 1
    expect(ul.note[0]).to be_instance_of RelatonBib::Element::Note
  end

  context "::parse_figure" do
    it "with paragraph" do
      node = Nokogiri::XML.fragment(<<~XML).children.first
        <figure id="ID" unnumbered="false" subsequence="SubSec" class="Cls">
          <source>source</source>
          <name>Tname</name>
          <p>text</p>
          <fn reference="ref"><p id="pID">FN</p></fn>
          <dl><dt>dt</dt></dl>
          <note id="nID"><p id="pID">note</p></note>
        </figure>
      XML
      figure = described_class.parse_figure node
      expect(figure).to be_instance_of RelatonBib::Element::Figure
      expect(figure.id).to eq "ID"
      expect(figure.unnumbered).to eq false
      expect(figure.subsequence).to eq "SubSec"
      expect(figure.klass).to eq "Cls"
      expect(figure.tname).to be_instance_of RelatonBib::Element::Tname
      expect(figure.content.size).to eq 1
      expect(figure.content[0]).to be_instance_of RelatonBib::Element::ParagraphWithFootnote
      expect(figure.note.size).to eq 1
      expect(figure.note[0]).to be_instance_of RelatonBib::Element::Note
    end

    it "with image" do
      node = Nokogiri::XML.fragment(<<~XML).children.first
        <figure id="ID"><image id="iID" src="/image.png" mimetype="image/png"></figure>
      XML
      figure = described_class.parse_figure node
      expect(figure).to be_instance_of RelatonBib::Element::Figure
      expect(figure.content).to be_instance_of RelatonBib::Element::Image
    end

    it "with audio" do
      node = Nokogiri::XML.fragment(<<~XML).children.first
        <figure id="ID"><audio id="aID" src="/audio.mp3" mimetype="audio/mp3"></figure>
      XML
      figure = described_class.parse_figure node
      expect(figure).to be_instance_of RelatonBib::Element::Figure
      expect(figure.content).to be_instance_of RelatonBib::Element::Audio
    end

    it "with video" do
      node = Nokogiri::XML.fragment(<<~XML).children.first
        <figure id="ID"><video id="vID" src="/video.mp4" mimetype="video/mp4"></figure>
      XML
      figure = described_class.parse_figure node
      expect(figure).to be_instance_of RelatonBib::Element::Figure
      expect(figure.content).to be_instance_of RelatonBib::Element::Video
    end

    it "with pre" do
      node = Nokogiri::XML.fragment(<<~XML).children.first
        <figure id="ID"><pre id="pID">code</pre></figure>
      XML
      figure = described_class.parse_figure node
      expect(figure).to be_instance_of RelatonBib::Element::Figure
      expect(figure.content).to be_instance_of RelatonBib::Element::Pre
    end

    it "with figure" do
      node = Nokogiri::XML.fragment(<<~XML).children.first
        <figure id="ID"><figure id="fID"><p>Text</p></figure></figure>
      XML
      figure = described_class.parse_figure node
      expect(figure).to be_instance_of RelatonBib::Element::Figure
      expect(figure.content.size).to eq 1
      expect(figure.content[0]).to be_instance_of RelatonBib::Element::Figure
    end
  end

  it "::parse_source" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <source type="src" language="en" locale="en-US" script="Lant">http://example.com</source>
    XML
    source = described_class.parse_source node
    expect(source).to be_instance_of RelatonBib::Element::Source
    expect(source.type).to eq "src"
    expect(source.language).to eq "en"
    expect(source.locale).to eq "en-US"
    expect(source.script).to eq "Lant"
    expect(source.content.to_s).to eq "http://example.com"
  end

  it "::parse_fn" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <fn reference="ref"><p id="pID">text</p></fn>
    XML
    fn = described_class.parse_fn node
    expect(fn).to be_instance_of RelatonBib::Element::Fn
    expect(fn.reference).to eq "ref"
    expect(fn.content.size).to eq 1
    expect(fn.content[0]).to be_instance_of RelatonBib::Element::Paragraph
  end

  it "::parse_video" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <video id="ID" src="/video.mp4" mimetype="video/mp4" filename="video.mp4" width="4" height="auto" alt="Alt" title="Title" longdesc="anyURI">
        <altsource src="/video.mp4" mimetype="video/mp4"/>
      </video>
    XML
    video = described_class.parse_video node
    expect(video).to be_instance_of RelatonBib::Element::Video
    expect(video.src).to eq "/video.mp4"
    expect(video.mimetype).to eq "video/mp4"
    expect(video.filename).to eq "video.mp4"
    expect(video.width).to eq "4"
    expect(video.height).to eq "auto"
    expect(video.alt).to eq "Alt"
    expect(video.title).to eq "Title"
    expect(video.longdesc).to eq "anyURI"
    expect(video.content.size).to eq 1
    expect(video.content[0]).to be_instance_of RelatonBib::Element::Altsource
  end

  it "::parse_audio" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <audio id="ID" src="/audio.mp3" mimetype="audio/mp3" filename="audio.mp3" alt="Alt" title="Title" longdesc="anyURI">
        <altsource src="/audio.mp3" mimetype="audio/mp3"/>
      </audio>
    XML
    audio = described_class.parse_audio node
    expect(audio).to be_instance_of RelatonBib::Element::Audio
    expect(audio.src).to eq "/audio.mp3"
    expect(audio.mimetype).to eq "audio/mp3"
    expect(audio.filename).to eq "audio.mp3"
    expect(audio.alt).to eq "Alt"
    expect(audio.title).to eq "Title"
    expect(audio.longdesc).to eq "anyURI"
    expect(audio.content.size).to eq 1
    expect(audio.content[0]).to be_instance_of RelatonBib::Element::Altsource
  end

  it "::parse_altsource" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <altsource src="/audio.mp3" mimetype="audio/mp3" filename="audio.mp3"/>
    XML
    altsource = described_class.parse_altsource node
    expect(altsource).to be_instance_of RelatonBib::Element::Altsource
    expect(altsource.src).to eq "/audio.mp3"
    expect(altsource.mimetype).to eq "audio/mp3"
    expect(altsource.filename).to eq "audio.mp3"
  end

  it "::parse_pre" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <pre id="ID" alt="Alt"><name>Tname</name>code<note id="nID"><p id="pID">Note</p></note></pre>
    XML
    pre = described_class.parse_pre node
    expect(pre).to be_instance_of RelatonBib::Element::Pre
    expect(pre.id).to eq "ID"
    expect(pre.alt).to eq "Alt"
    expect(pre.tname).to be_instance_of RelatonBib::Element::Tname
    expect(pre.content).to be_instance_of RelatonBib::Element::Text
    expect(pre.note.size).to eq 1
    expect(pre.note[0]).to be_instance_of RelatonBib::Element::Note
  end

  it "::parse_quote" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <quote id="ID" alignment="left">
        <source citeas="ref" type="inline" bibitemid="IDREF">Source</source>
        <author>Author</author>
        <p>text</p>
        <note id="nID"><p id="pID">note</p></note>
      </quote>
    XML
    quote = described_class.parse_quote node
    expect(quote).to be_instance_of RelatonBib::Element::Quote
    expect(quote.id).to eq "ID"
    expect(quote.alignment).to eq "left"
    expect(quote.source).to be_instance_of RelatonBib::Element::Quote::Source
    expect(quote.author).to be_instance_of RelatonBib::Element::Quote::Author
    expect(quote.content.size).to eq 1
    expect(quote.content[0]).to be_instance_of RelatonBib::Element::ParagraphWithFootnote
    expect(quote.note.size).to eq 1
    expect(quote.note[0]).to be_instance_of RelatonBib::Element::Note
  end

  it "::parse_sourcecode" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <sourcecode id="ID" unnumbered="false" subsequence="SubSec" lang="en">
        <name>Tname</name>code<callout target="IDREF">Callout</callout>
        <annotation id="aID"><p id="pID">Annotation</p></annotation>
        <note id="nID"><p id="pID">Note</p></note>
      </sourcecode>
    XML
    sourcecode = described_class.parse_sourcecode node
    expect(sourcecode).to be_instance_of RelatonBib::Element::Sourcecode
    expect(sourcecode.id).to eq "ID"
    expect(sourcecode.unnumbered).to eq false
    expect(sourcecode.subsequence).to eq "SubSec"
    expect(sourcecode.lang).to eq "en"
    expect(sourcecode.tname).to be_instance_of RelatonBib::Element::Tname
    expect(sourcecode.content.size).to eq 2
    expect(sourcecode.content[0]).to be_instance_of RelatonBib::Element::Text
    expect(sourcecode.content[1]).to be_instance_of RelatonBib::Element::Callout
    expect(sourcecode.annotation.size).to eq 1
    expect(sourcecode.annotation[0]).to be_instance_of RelatonBib::Element::Annotation
    expect(sourcecode.note.size).to eq 1
    expect(sourcecode.note[0]).to be_instance_of RelatonBib::Element::Note
  end

  it "::parse_example" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <example id="ID" unnumbered="false" subsequence="SubSec">
        <name>Tname</name>
        <formula id="ID"><stem type="MathML">Stem</stem></formula>
        <ul id="ID"><li><p>item</p></li></ul>
        <ol id="ID"><li><p>item</p></li></ol>
        <dl id="ID"><dt>dt</dt></dl>
        <quote id="ID"><p>text</p></quote>
        <sourcecode id="ID"><p>code</p></sourcecode>
        <p>text</p>
        <note id="nID"><p id="pID">note</p></note>
      </example>
    XML
    example = described_class.parse_example node
    expect(example).to be_instance_of RelatonBib::Element::Example
    expect(example.id).to eq "ID"
    expect(example.unnumbered).to eq false
    expect(example.subsequence).to eq "SubSec"
    expect(example.tname).to be_instance_of RelatonBib::Element::Tname
    expect(example.content.size).to eq 7
    expect(example.content[0]).to be_instance_of RelatonBib::Element::Formula
    expect(example.content[1]).to be_instance_of RelatonBib::Element::Ul
    expect(example.content[2]).to be_instance_of RelatonBib::Element::Ol
    expect(example.content[3]).to be_instance_of RelatonBib::Element::Dl
    expect(example.content[4]).to be_instance_of RelatonBib::Element::Quote
    expect(example.content[5]).to be_instance_of RelatonBib::Element::Sourcecode
    expect(example.content[6]).to be_instance_of RelatonBib::Element::ParagraphWithFootnote
    expect(example.note.size).to eq 1
    expect(example.note[0]).to be_instance_of RelatonBib::Element::Note
  end

  it "::parse_review" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <review id="ID" reviewer="Reviewer" type="Type" date="2001-02-01T12:00:00" from="IDREF" to="IDREF">
        <p id="pID">text</p>
      </review>
    XML
    review = described_class.parse_review node
    expect(review).to be_instance_of RelatonBib::Element::Review
    expect(review.id).to eq "ID"
    expect(review.reviewer).to eq "Reviewer"
    expect(review.type).to eq "Type"
    expect(review.date).to eq "2001-02-01T12:00:00"
    expect(review.from).to eq "IDREF"
    expect(review.to).to eq "IDREF"
    expect(review.content.size).to eq 1
    expect(review.content[0]).to be_instance_of RelatonBib::Element::Paragraph
  end

  it "::parse_amend" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <amend id="ID" change="add" path="Path" path_end="Path End" title="Title">
        <location><locality type="clause"/></location>
        <description><p>text</p></description>
        <newcontent id="ncID"><p>new content</p></newcontent>
        <classification><tag>Tag</tag><value>Value</value></classification>
        <contributor>
          <role type="author"/>
          <organization><name>Org</name></organization>
        </contributor>
      </amend>
    XML
    amend = described_class.parse_amend node
    expect(amend).to be_instance_of RelatonBib::Element::Amend
    expect(amend.id).to eq "ID"
    expect(amend.path).to eq "Path"
    expect(amend.path_end).to eq "Path End"
    expect(amend.title).to eq "Title"
    expect(amend.location).to be_instance_of RelatonBib::Element::AmendType::Location
    expect(amend.description).to be_instance_of RelatonBib::Element::AmendType::Description
    expect(amend.newcontent).to be_instance_of RelatonBib::Element::AmendType::Newcontent
    expect(amend.classification.size).to eq 1
    expect(amend.classification[0]).to be_instance_of RelatonBib::Element::Classification
    expect(amend.contributor.size).to eq 1
    expect(amend.contributor[0]).to be_instance_of RelatonBib::Contributor
  end

  it "::parse_classification" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <classification><tag>Tag</tag><value>Value</value></classification>
    XML
    classification = described_class.parse_classification node
    expect(classification).to be_instance_of RelatonBib::Element::Classification
    expect(classification.tag).to be_instance_of RelatonBib::Element::Classification::Tag
    expect(classification.tag.content).to eq "Tag"
    expect(classification.value).to be_instance_of RelatonBib::Element::Classification::Value
    expect(classification.value.content).to eq "Value"
  end

  it "::parse_amend_location" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <location><locality type="clause"/></location>
    XML
    location = described_class.parse_amend_location node
    expect(location).to be_instance_of RelatonBib::Element::AmendType::Location
    expect(location.content.size).to eq 1
    expect(location.content[0]).to be_instance_of RelatonBib::Locality
  end

  it "::parse_amend_description" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <description><p>text</p></description>
    XML
    description = described_class.parse_amend_description node
    expect(description).to be_instance_of RelatonBib::Element::AmendType::Description
    expect(description.content.size).to eq 1
    expect(description.content[0]).to be_instance_of RelatonBib::Element::ParagraphWithFootnote
  end

  it "::parse_amend_newcontent" do
    node = Nokogiri::XML.fragment(<<~XML).children.first
      <newcontent id="ID"><p>new content</p></newcontent>
    XML
    newcontent = described_class.parse_amend_newcontent node
    expect(newcontent).to be_instance_of RelatonBib::Element::AmendType::Newcontent
    expect(newcontent.id).to eq "ID"
    expect(newcontent.content.size).to eq 1
    expect(newcontent.content[0]).to be_instance_of RelatonBib::Element::ParagraphWithFootnote
  end

  context "::string_to_bool" do
    it "true" do
      expect(described_class.string_to_bool("true")).to be true
    end

    it "false" do
      expect(described_class.string_to_bool("false")).to be false
    end

    it "other" do
      expect(described_class.string_to_bool("text")).to be nil
    end
  end
end
