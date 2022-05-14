RSpec.describe RelatonBib::LocalizedString do
  it "raise ArgumentError" do
    expect do
      RelatonBib::LocalizedString.new []
    end.to raise_error ArgumentError, "LocalizedString content is empty"
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

    it "escape &" do
      xml = Nokogiri::XML::Builder.new do |b|
        b.localized_string { subject.to_xml(b) }
      end
      expect(xml.doc.root.to_s).to be_equivalent_to <<~XML
        <localized_string language="en" script="Latn">
          prefix <p>content <p>&lt; &amp; &gt; characters</p> to escape</p><p>Text</p> suffix
        </localized_string>
      XML
    end
  end
end
