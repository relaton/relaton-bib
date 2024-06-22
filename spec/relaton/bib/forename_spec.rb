describe Relaton::Bib::Forename do
  subject do
    described_class.new content: "John", language: "en", script: "Latn", initial: "J"
  end

  it "initialize" do
    expect(subject.content).to eq "John"
    expect(subject.language).to eq ["en"]
    expect(subject.script).to eq ["Latn"]
    expect(subject.initial).to eq "J"
  end

  context "instance methods" do
    it "#to_xml" do
      doc = Nokogiri::XML::Builder.new do |builder|
        builder.name { subject.to_xml builder }
      end.doc.root
      expect(doc.to_xml).to be_equivalent_to <<-XML
        <name>
          <forename language="en" script="Latn" initial="J">John</forename>
        </name>
      XML
    end

    it "#to_hash" do
      expect(subject.to_hash).to eq(
        { "content" => "John", "language" => ["en"], "script" => ["Latn"],
          "initial" => "J" },
      )
    end

    context "#to_asciibib" do
      it "single forename" do
        expect(subject.to_asciibib("name", 1)).to eq <<~ASCIIDOC
          name.forename.content:: John
          name.forename.language:: en
          name.forename.script:: Latn
          name.forename.initial:: J
        ASCIIDOC
      end

      it "multiple forenames" do
        expect(subject.to_asciibib("name", 2)).to eq <<~ASCIIDOC
          name.forename::
          name.forename.content:: John
          name.forename.language:: en
          name.forename.script:: Latn
          name.forename.initial:: J
        ASCIIDOC
      end
    end
  end
end
