describe Relaton::Bib::Source do
  it "set content" do
    uri = described_class.new type: "src", content: nil
    uri.content = "http://example.com"
    expect(uri.content).to be_instance_of Addressable::URI
    expect(uri.content.to_s).to eq "http://example.com"
  end

  context "instance methods" do
    subject do
      described_class.new type: "src", content: "http://example.com", language: "en", script: "Latn"
    end

    it "#to_xml" do
      builder = Nokogiri::XML::Builder.new
      subject.to_xml(builder)
      expect(builder.doc.root.to_xml).to be_equivalent_to <<~XML
        <uri type="src" language="en" script="Latn">http://example.com</uri>
      XML
    end

    it "#to_asciibib" do
      expect(subject.to_asciibib("org")).to eq <<~OUTPUT
        org.link.type:: src
        org.link.content:: http://example.com
        org.link.language:: en
        org.link.script:: Latn
      OUTPUT
    end

    it "#to_hash" do
      expect(subject.to_hash).to eq(
        "content" => "http://example.com",
        "type" => "src",
        "language" => "en",
        "script" => "Latn",
      )
    end
  end
end
