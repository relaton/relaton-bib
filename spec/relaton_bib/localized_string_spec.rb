RSpec.describe RelatonBib::LocalizedString do
  it "raise ArgumentError" do
    expect do
      RelatonBib::LocalizedString.new []
    end.to raise_error ArgumentError, "LocalizedString content is empty"
  end

  it "create with Aray<String> content" do
    ls = RelatonBib::LocalizedString.new ["Content"]
    expect(ls.content[0].content).to eq "Content"
  end

  context "instance" do
    subject do
      RelatonBib::LocalizedString.new(<<-XML, "en", "Latn")
        prefix <p>content <p>< & > characters</p> to escape</p>
        <p>Text</p> suffix
      XML
    end

    it "returns false" do
      expect(subject.empty?).to be false
    end

    context "escape" do
      it "&" do
        xml = Nokogiri::XML::Builder.new do |b|
          b.localized_string { subject.to_xml(b) }
        end
        expect(xml.doc.root.to_s).to be_equivalent_to <<~XML
          <localized_string language="en" script="Latn">
            prefix <p>content <p>&lt; &amp; &gt; characters</p> to escape</p><p>Text</p> suffix
          </localized_string>
        XML
      end

      it "incorrect XML" do
        ls = RelatonBib::LocalizedString.new <<~XML, "en", "Latn"
          <p><p>Content</t></p>
        XML
        xml = Nokogiri::XML::Builder.new do |b|
          b.localized_string { ls.to_xml(b) }
        end
        expect(xml.doc.root.to_s).to be_equivalent_to <<~XML
          <localized_string language="en" script="Latn">
            <p>&lt;p&gt;Content&lt;/t&gt;</p>
          </localized_string>
        XML
      end

      it "content with 2 root elements" do
        ls = RelatonBib::LocalizedString.new <<~XML, "en", "Latn"
          <p>Content &</p><p>Content</p>
        XML
        xml = Nokogiri::XML::Builder.new do |b|
          b.localized_string { ls.to_xml(b) }
        end
        expect(xml.doc.root.to_s).to be_equivalent_to <<~XML
          <localized_string language="en" script="Latn">
            <p>Content &amp;</p><p>Content</p>
          </localized_string>
        XML
      end

      it "tag with attributes" do
        ls = RelatonBib::LocalizedString.new <<~XML, "en", "Latn"
          <p>Content <p id="1">Content</p></p>
        XML
        xml = Nokogiri::XML::Builder.new do |b|
          b.localized_string { ls.to_xml(b) }
        end
        expect(xml.doc.root.to_s).to be_equivalent_to <<~XML
          <localized_string language="en" script="Latn">
            <p>Content <p id="1">Content</p></p>
          </localized_string>
        XML
      end

      it "tag without content" do
        ls = RelatonBib::LocalizedString.new <<~XML, "en", "Latn"
          <link href="http://example.com"/>
        XML
        xml = Nokogiri::XML::Builder.new do |b|
          b.localized_string { ls.to_xml(b) }
        end
        expect(xml.doc.root.to_s).to be_equivalent_to <<~XML
          <localized_string language="en" script="Latn">
            <link href="http://example.com"/>
          </localized_string>
        XML
      end
    end
  end
end
