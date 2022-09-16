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
  end
end
