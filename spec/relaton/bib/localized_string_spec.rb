describe Relaton::Bib::LocalizedString do
  context "instance" do
    subject do
      described_class.new(<<-XML, "en", "Latn")
        prefix <p>content <p>< & > characters</p> to escape</p>
        <p>Text</p> suffix
      XML
    end

    it "returns false" do
      expect(subject.empty?).to be false
    end

    it "escape HTML" do
      xml = Nokogiri::XML::Builder.new do |b|
        b.localized_string { subject.to_xml(b) }
      end
      expect(xml.doc.root.to_s).to be_equivalent_to <<~XML
        <localized_string language="en" script="Latn">
          prefix &lt;p&gt;content &lt;p&gt;&lt; &amp; &gt; characters&lt;/p&gt; to escape&lt;/p&gt;
          &lt;p&gt;Text&lt;/p&gt; suffix
        </localized_string>
      XML
    end

    it "don't escape HTML entities" do
      ls = described_class.new "Content &amp;", "en", "Latn"
      xml = Nokogiri::XML::Builder.new do |b|
        b.localized_string { ls.to_xml(b) }
      end
      expect(xml.doc.root.to_s).to be_equivalent_to <<~XML
        <localized_string language="en" script="Latn">Content &amp;</localized_string>
      XML
    end

    it "escape String content only" do
      ls = described_class.new [described_class.new("Content <p>Text</p>", "en", "Latn")]
      xml = Nokogiri::XML::Builder.new do |b|
        b.localized_string { ls.to_xml(b) }
      end
      expect(xml.doc.root.to_s).to be_equivalent_to <<~XML
        <localized_string>
          <variant language="en" script="Latn">Content &lt;p&gt;Text&lt;/p&gt;</variant>
        </localized_string>
      XML
    end
  end
end
