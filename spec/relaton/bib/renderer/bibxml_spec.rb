describe Relaton::Bib::BibXML do
  context "instance methods" do
    subject { described_class.new bibitem }
    let(:bibitem) { Relaton::Bib::ItemData.new(docidentifier: docid) }

    context "ref_attrs" do
      let(:docid) { [(Relaton::Bib::Docidentifier.new content: "IANA dns-parameters", type: "IANA")] }
      it "upcase anchor for IANA" do
        ref_attrs = subject.ref_attrs
        expect(ref_attrs).to be_instance_of Hash
        expect(ref_attrs[:anchor]).to eq "DNS-PARAMETERS"
      end
    end

    context "render_seriesinfo" do
      let(:docid) do
        [Relaton::Bib::Docidentifier.new(content: "IEEE 123", type: "IEEE"),
         Relaton::Bib::Docidentifier.new(content: "IEEE 123", type: "IEEE", scope: "trademark")]
      end
      it "do not render trademark" do
        builder = double "builder"
        expect(builder).to receive(:seriesInfo).with(name: "IEEE", value: "IEEE 123").once
        subject.render_seriesinfo builder
      end
    end
  end
end
