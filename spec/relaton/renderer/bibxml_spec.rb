describe Relaton::Renderer::BibXML do
  context "instance methods" do
    context "ref_attrs" do
      xit "upcase anchor for IANA" do
        docid = Relaton::Bib::Docidentifier.new id: "IANA dns-parameters", type: "IANA"
        bib = Relaton::Bib::Item.new(docid: [docid])
        renderer = Relaton::Renderer::BibXML.new bib
        ref_attrs = renderer.ref_attrs
        expect(ref_attrs).to be_instance_of Hash
        expect(ref_attrs[:anchor]).to eq "DNS-PARAMETERS"
      end
    end

    context "render_seriesinfo" do
      xit "do not render trademark" do
        docid = [
          Relaton::Bib::Docidentifier.new(id: "IEEE 123", type: "IEEE"),
          Relaton::Bib::Docidentifier.new(id: "IEEE 123", type: "IEEE", scope: "trademark"),
        ]
        bib = Relaton::Bib::Item.new docid: docid
        renderer = Relaton::Bib::Renderer::BibXML.new bib
        builder = double "builder"
        # expect(builder).to receive(:seriesInfo).with(name: "IEEE", value: "IEEE 123").once
        renderer.render_seriesinfo builder
      end
    end
  end
end
