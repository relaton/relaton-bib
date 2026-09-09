describe Relaton::Bib::Sanitizer do
  describe ".sanitize" do
    it "returns nil unchanged" do
      expect(described_class.sanitize(nil)).to be_nil
    end

    it "returns empty string unchanged" do
      expect(described_class.sanitize("")).to eq ""
    end

    it "returns plain text unchanged" do
      expect(described_class.sanitize("just text")).to eq "just text"
    end

    it "leaves strings without tags untouched even when they contain '<'" do
      text = "x < 5 and a < b"
      expect(described_class.sanitize(text)).to eq text
    end

    it "preserves non-string input" do
      expect(described_class.sanitize(42)).to eq 42
    end

    described_class::ALLOWED.each do |tag|
      it "preserves the <#{tag}> tag" do
        input = "<#{tag}>x</#{tag}>"
        expect(described_class.sanitize(input)).to eq input
      end
    end

    it "preserves attributes on allowed elements" do
      input = '<eref bibitemid="ref1">link</eref>'
      expect(described_class.sanitize(input)).to eq input
    end

    it "preserves an inline <link> with its target attribute (#122)" do
      input = '<link target="https://x.org">L</link>'
      expect(described_class.sanitize(input)).to eq input
    end

    it "preserves <br/> self-closing tag" do
      expect(described_class.sanitize("a<br/>b")).to eq "a<br/>b"
    end

    it "strips a disallowed tag, keeping inner text" do
      expect(described_class.sanitize("<script>bad</script>"))
        .to eq "bad"
    end

    it "strips disallowed tags nested inside allowed tags" do
      expect(described_class.sanitize("<p>good <script>bad</script></p>"))
        .to eq "<p>good bad</p>"
    end

    it "strips disallowed tags wrapping allowed tags" do
      expect(described_class.sanitize("<div><em>kept</em></div>"))
        .to eq "<em>kept</em>"
    end

    it "preserves mixed allowed inline markup" do
      input = "Hello <em>world</em> <strong>now</strong>"
      expect(described_class.sanitize(input)).to eq input
    end

    it "preserves non-ASCII characters literally (no numeric entities)" do
      input = "1<sup>e</sup> réunion"
      expect(described_class.sanitize(input)).to eq input
    end

    it "is idempotent" do
      input = "<p>a <foo>b <em>c</em></foo></p>"
      once  = described_class.sanitize(input)
      twice = described_class.sanitize(once)
      expect(twice).to eq once
    end

    # The serialiser drops Nokogiri's FORMAT option, so element-only
    # content keeps its shape instead of gaining newlines and indent.
    it "does not indent element-only content" do
      input = "<p><em>x</em></p>"
      expect(described_class.sanitize(input)).to eq input
    end

    it "does not indent a nested element-only body" do
      input = "<fn><p>x</p></fn>"
      expect(described_class.sanitize(input)).to eq input
    end

    it "renames <italic> to <em>" do
      expect(described_class.sanitize("<italic>h</italic>"))
        .to eq "<em>h</em>"
    end

    it "renames nested <italic> alongside allowed siblings" do
      input    = "values of <italic>h</italic>, <italic>N</italic>" \
                 "<sub>A</sub>"
      expected = "values of <em>h</em>, <em>N</em><sub>A</sub>"
      expect(described_class.sanitize(input)).to eq expected
    end

    it "preserves <fn> wrapping a <p> body (footnote in title)" do
      input = 'Cereals and cereal products' \
              '<fn reference="7"><p id="_x">ISO is a standards ' \
              'organisation.</p></fn>'
      output = described_class.sanitize(input)
      expect(output).to include('<fn reference="7">')
      expect(output).to include('<p id="_x">')
      expect(output).to include('ISO is a standards organisation.')
      expect(output).to include('</fn>')
    end

    # Undeclared namespace prefixes. Third-party markup (JATS from
    # Crossref, for example) prefixes its elements, and Relaton never
    # declares the prefix. Nokogiri reports an undeclared prefix as a
    # parse error, so the sanitiser used to return the content
    # untouched -- exactly the input that needs sanitising most. The
    # unparseable output then reached relaton-render, which returned
    # nil, and isodoc raised NoMethodError. See metanorma-pdfa#99.
    context "with undeclared namespace prefixes" do
      it "maps prefixed markup to the basicdoc set" do
        input = "<jats:p><jats:italic>x</jats:italic></jats:p>"
        expect(described_class.sanitize(input)).to eq "<p><em>x</em></p>"
      end

      it "unwraps prefixed elements outside the allow-list" do
        input = "<ns:sec><ns:title>H</ns:title><ns:p>B</ns:p></ns:sec>"
        expect(described_class.sanitize(input)).to eq "H<p>B</p>"
      end

      it "drops a prefixed attribute" do
        input = '<jats:p><jats:ext-link xlink:href="http://a.b">A' \
                "</jats:ext-link></jats:p>"
        expect(described_class.sanitize(input)).to eq "<p>A</p>"
      end

      it "keeps a declared namespace alongside an undeclared prefix" do
        math = '<math xmlns="http://www.w3.org/1998/Math/MathML">' \
               "<mi>d</mi></math>"
        input = "<jats:p><stem>#{math}</stem></jats:p>"
        expect(described_class.sanitize(input))
          .to eq "<p><stem>#{math}</stem></p>"
      end

      it "drops an undeclared prefix inside an opaque <stem>" do
        # <stem> content survives verbatim, but an undeclared prefix
        # cannot: it is the exact failure this path removes.
        input = "<jats:p><stem><mml:math><mml:mi>d</mml:mi></mml:math>" \
                "</stem></jats:p>"
        expect(described_class.sanitize(input))
          .to eq "<p><stem><math><mi>d</mi></math></stem></p>"
      end

      it "sanitises content that holds the wrapper element" do
        # A guessable wrapper name would let the content close the
        # wrapper early, and the sanitiser would give up on it.
        input = "<jats:p><relaton-sanitizer-root>a" \
                "</relaton-sanitizer-root></jats:p>"
        expect(described_class.sanitize(input)).to eq "<p>a</p>"
      end

      it "keeps a namespace that reuses the placeholder URI" do
        input = '<jats:p><stem><x:m xmlns:x="urn:x-relaton-undeclared:x">' \
                "d</x:m></stem></jats:p>"
        expect(described_class.sanitize(input))
          .to eq '<p><stem><x:m xmlns:x="urn:x-relaton-undeclared:x">' \
                 "d</x:m></stem></p>"
      end

      it "is idempotent on prefixed input" do
        input = "<jats:p>a <jats:italic>b</jats:italic></jats:p>"
        once  = described_class.sanitize(input)
        twice = described_class.sanitize(once)
        expect(twice).to eq once
      end

      it "leaves unbalanced markup untouched" do
        expect(described_class.sanitize("<p>unbalanced")).to eq "<p>unbalanced"
      end

      it "leaves text that only looks like a prefixed tag untouched" do
        text = "Vector<T:Clone> in Rust"
        expect(described_class.sanitize(text)).to eq text
      end
    end

    # Opaque-stem cases (#116): <stem> holds out-of-band notation
    # (MathML, AsciiMath, LaTeX) that the sanitiser must preserve
    # rather than recurse into. Assertions are include-shaped because
    # the SEMANTIC claim is "inner elements survive, not just their text
    # content". Nokogiri no longer reflows whitespace around nested
    # elements: SAVE_OPTS drops the FORMAT option.
    it "preserves MathML inner elements inside <stem> (does not unwrap to text)" do
      input  = 'Prefix <stem><math><mi>d</mi><mn>6</mn></math>' \
               '<asciimath>d_6</asciimath></stem> Suffix'
      output = described_class.sanitize(input)
      expect(output).to include("<math>")
      expect(output).to include("<mi>d</mi>")
      expect(output).to include("<mn>6</mn>")
      expect(output).to include("<asciimath>d_6</asciimath>")
      # Negative: pre-fix the inner elements were unwrapped to bare
      # text, producing "<stem>d6d_6</stem>". Make sure that exact
      # collapsed shape does not reappear.
      expect(output).not_to match(/<stem>\s*d\s*6\s*d_6\s*<\/stem>/)
    end

    it "preserves <stem> attributes alongside opaque MathML content" do
      input  = 'a-<stem block="false" type="MathML">' \
               '<math xmlns="http://www.w3.org/1998/Math/MathML">' \
               '<mstyle displaystyle="false"><msub><mi>d</mi><mn>6</mn>' \
               '</msub></mstyle></math><asciimath>d_6</asciimath>' \
               '</stem> [ISRD-07]'
      output = described_class.sanitize(input)
      expect(output).to include('<stem block="false" type="MathML">')
      # The MathML namespace must survive verbatim -- the whole point of
      # basicdoc-models#35 ("namespace and all"). lutaml-model (0.8.16)
      # preserves it through the map_all raw round-trip in both XML and
      # key-value; this guards the Sanitizer half, and would fail loudly if
      # the opaque-stem handling (#116/#117) were reverted.
      expect(output)
        .to include('<math xmlns="http://www.w3.org/1998/Math/MathML">')
      expect(output).to include('<mstyle displaystyle="false">')
      expect(output).to include('<msub>')
      expect(output).to include('<mi>d</mi>')
      expect(output).to include('<mn>6</mn>')
      expect(output).to include('<asciimath>d_6</asciimath>')
      expect(output).to include('[ISRD-07]')
    end

    it "still sanitises siblings of <stem> while leaving stem opaque" do
      input  = '<script>bad</script> a-<stem><math><mi>x</mi></math>' \
               '</stem> <em>ok</em>'
      output = described_class.sanitize(input)
      expect(output).not_to include("<script>")
      expect(output).to include("bad ")
      expect(output).to include("<math>")
      expect(output).to include("<mi>x</mi>")
      expect(output).to include("<em>ok</em>")
    end
  end
end

describe Relaton::Bib::LocalizedMarkedUpString do
  it "sanitizes content on assignment" do
    str = described_class.new(content: "<em>ok</em><script>bad</script>")
    expect(str.content).to eq "<em>ok</em>bad"
  end

  it "sanitizes content on direct setter call" do
    str = described_class.new
    str.content = "<p>x</p><evil/>"
    expect(str.content).to eq "<p>x</p>"
  end

  it "passes nil content through" do
    str = described_class.new(content: nil)
    expect(str.content).to be_nil
  end

  # Regression for #122: a biblionote round-trip must not drop an inline
  # <link> (keeping only its text and losing the target URL). metanorma's
  # amend() rebuilds merged bibitems via from_xml -> to_xml, so a dropped
  # <link> silently discards every URL in span:note.display references.
  it "preserves an inline <link> in a note through a Bibitem round-trip" do
    xml = '<bibitem id="x"><title>T</title>' \
          '<note type="display">a <link target="https://x.org">L</link> b' \
          "</note></bibitem>"
    output = Relaton::Bib::Bibitem.from_xml(xml).to_xml
    expect(output).to include('<link target="https://x.org">L</link>')
  end
end
