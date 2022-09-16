describe RelatonBib::FormattedString do
  context "instance" do
    subject do
      RelatonBib::FormattedString.new(content: <<-XML, language: "en", script: "Latn", format: "text/html")
        prefix <p>content <p>< & > characters</p> to escape</p>
        <p>Text</p> suffix
      XML
    end

    context "escape" do
      it "&" do
        xml = Nokogiri::XML::Builder.new do |b|
          b.formatted_string { subject.to_xml(b) }
        end
        expect(xml.doc.root.to_s).to be_equivalent_to <<~XML
          <formatted_string format="text/html" language="en" script="Latn">
            prefix <p>content <p>&lt; &amp; &gt; characters</p> to escape</p><p>Text</p> suffix
          </formatted_string>
        XML
      end

      it "incorrect HTML" do
        ls = RelatonBib::FormattedString.new content: <<~XML, language: "en", script: "Latn", format: "text/html"
          <p><p>Content</t></p>
        XML
        xml = Nokogiri::XML::Builder.new do |b|
          b.formatted_string { ls.to_xml(b) }
        end
        expect(xml.doc.root.to_s).to be_equivalent_to <<~XML
          <formatted_string format="text/html" language="en" script="Latn">
            <p>&lt;p&gt;Content&lt;/t&gt;</p>
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
          <link href="http://example.com"/>
        XML
        xml = Nokogiri::XML::Builder.new do |b|
          b.formatted_string { ls.to_xml(b) }
        end
        expect(xml.doc.root.to_s).to be_equivalent_to <<~XML
          <formatted_string format="text/html">
            <link href="http://example.com"/>
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
  end
end
