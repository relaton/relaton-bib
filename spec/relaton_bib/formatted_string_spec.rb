describe RelatonBib::FormattedString do
  context "instance" do
    subject do
      RelatonBib::FormattedString.new(content: <<-XML, language: "en", script: "Latn", format: "text/html")
        prefix <p>content <p>< & > characters</p> to escape</p>
        <p>Text \xC2\xB1 10-4 K</p> suffix
      XML
    end

    context "escape" do
      it "&" do
        xml = Nokogiri::XML::Builder.new do |b|
          b.formatted_string { subject.to_xml(b) }
        end
        expect(xml.doc.root.to_s).to be_equivalent_to <<~XML
          <formatted_string format="text/html" language="en" script="Latn">
            prefix<p>content<p>&lt; &amp; &gt; characters</p>to escape</p><p>Text &#xB1; 10-4 K</p> suffix
          </formatted_string>
        XML
      end

      it "incorrect HTML" do
        ls = RelatonBib::FormattedString.new content: <<~XML, language: "en", script: "Latn", format: "text/html"
          <p><p>Content</tt></p>
        XML
        xml = Nokogiri::XML::Builder.new do |b|
          b.formatted_string { ls.to_xml(b) }
        end
        expect(xml.doc.root.to_s).to be_equivalent_to <<~XML
          <formatted_string format="text/html" language="en" script="Latn">
            <p>&lt;p&gt;Content&lt;/tt&gt;</p>
          </formatted_string>
        XML
      end

      it "content with 2 root elements" do
        ls = RelatonBib::FormattedString.new content: <<~XML, format: "text/html"
          <p>Content &</p><p>Content</p>
        XML
        xml = Nokogiri::XML::Builder.new do |b|
          b.formatted_string { ls.to_xml(b) }
        end
        expect(xml.doc.root.to_s).to be_equivalent_to <<~XML
          <formatted_string format="text/html">
            <p>Content &amp;</p><p>Content</p>
          </formatted_string>
        XML
      end

      it "tag with attributes" do
        ls = RelatonBib::FormattedString.new content: <<~XML, format: "text/html"
          <p>Content <p id="1">Content</p></p>
        XML
        xml = Nokogiri::XML::Builder.new do |b|
          b.formatted_string { ls.to_xml(b) }
        end
        expect(xml.doc.root.to_s).to be_equivalent_to <<~XML
          <formatted_string format="text/html">
            <p>Content <p id="1">Content</p></p>
          </formatted_string>
        XML
      end

      it "tag without content" do
        ls = RelatonBib::FormattedString.new content: <<~XML, format: "text/html"
          <br/><br />
        XML
        xml = Nokogiri::XML::Builder.new do |b|
          b.formatted_string { ls.to_xml(b) }
        end
        expect(xml.doc.root.to_s).to be_equivalent_to <<~XML
          <formatted_string format="text/html">
            <br/><br/>
          </formatted_string>
        XML
      end

      it "HTML comment" do
        ls = RelatonBib::FormattedString.new content: <<~XML, format: "text/html"
          <p>Content <!-- comment --> Content</p>
        XML
        xml = Nokogiri::XML::Builder.new do |b|
          b.formatted_string { ls.to_xml(b) }
        end
        expect(xml.doc.root.to_s).to be_equivalent_to <<~XML
          <formatted_string format="text/html">
            <p>Content <!-- comment --> Content</p>
          </formatted_string>
        XML
      end
    end

    it "cleanup" do
      fs = described_class.new content: <<~XML, format: "text/html"
        <i>Italic</i> <b>Bold</b> <u>Underline</u> <sup>Superscript</sup> <sub>Subscript</sub><br/>
        <jats:p>Paragraph</jats:p><tt>Monospace</tt><a href="http://example.com">Link</a>
        <italic>Italic</italic>.
      XML
      expect(fs.content).to be_equivalent_to <<~XML
        <em>Italic</em> <strong>Bold</strong> Underline <sup>Superscript</sup> <sub>Subscript</sub><br/>
        <p>Paragraph</p><tt>Monospace</tt>Link
        Italic.
      XML
    end
  end
end
