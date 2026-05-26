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
end
