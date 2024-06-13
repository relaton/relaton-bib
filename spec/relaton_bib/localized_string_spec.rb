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

  it "create with String content" do
    ls = RelatonBib::LocalizedString.new "Content"
    expect(ls.content).to eq "Content"
  end

  it "create with Hash content" do
    ls = RelatonBib::LocalizedString.new [content: "Content"]
    expect(ls.content[0].content).to eq "Content"
  end

  context "escape entities" do
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
  end

  context "to_xml" do
    it "without variants" do
      ls = described_class.new "Name", "en", "Latn"
      xml = Nokogiri::XML::Builder.new { |b| b.name { ls.to_xml(b) } }
      expect(xml.doc.root.to_s).to be_equivalent_to <<~XML
        <name language="en" script="Latn">Name</name>
      XML
    end

    it "with variants" do
      ls = described_class.new [content: "Name", language: "en", script: "Latn"]
      xml = Nokogiri::XML::Builder.new { |b| b.name { ls.to_xml(b) } }
      expect(xml.doc.root.to_s).to be_equivalent_to <<~XML
        <name><variant language="en" script="Latn">Name</variant></name>
      XML
    end
  end

  context "to_h" do
    it "without variants" do
      ls = described_class.new "Name", "en", "Latn"
      expect(ls.to_h).to eq("content" => "Name", "language" => ["en"], "script" => ["Latn"])
    end

    it "with variants" do
      ls = described_class.new [content: "Name", language: "en", script: "Latn"]
      expect(ls.to_h).to eq(
        [{ "content" => "Name", "language" => ["en"], "script" => ["Latn"] }],
      )
    end
  end

  context "to_asciibib" do
    it "without variants" do
      ls = described_class.new "Name", "en", "Latn"
      expect(ls.to_asciibib).to eq <<~TEXT
        content:: Name
        language:: en
        script:: Latn
      TEXT
    end

    it "with variants" do
      ls = described_class.new [content: "Name", language: "en", script: "Latn"]
      expect(ls.to_asciibib).to eq <<~TEXT
        variant.content:: Name
        variant.language:: en
        variant.script:: Latn
      TEXT
    end
  end
end
