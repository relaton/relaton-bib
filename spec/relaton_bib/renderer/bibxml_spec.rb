describe RelatonBib::Renderer::BibXML do
  context "instance methods" do
    context "ref_attrs" do
      it "upcase anchor for IANA" do
        docid = RelatonBib::DocumentIdentifier.new id: "IANA dns-parameters", type: "IANA"
        bib = RelatonBib::BibliographicItem.new(docid: [docid])
        renderer = RelatonBib::Renderer::BibXML.new bib
        ref_attrs = renderer.ref_attrs
        expect(ref_attrs).to be_instance_of Hash
        expect(ref_attrs[:anchor]).to eq "DNS-PARAMETERS"
      end
    end

    context "render_seriesinfo" do
      it "do not render trademark" do
        docid = [
          RelatonBib::DocumentIdentifier.new(id: "IEEE 123", type: "IEEE"),
          RelatonBib::DocumentIdentifier.new(id: "IEEE 123", type: "IEEE", scope: "trademark"),
        ]
        bib = RelatonBib::BibliographicItem.new docid: docid
        renderer = RelatonBib::Renderer::BibXML.new bib
        builder = double "builder"
        # expect(builder).to receive(:seriesInfo).with(name: "IEEE", value: "IEEE 123").once
        renderer.render_seriesinfo builder
      end
    end
  end
end
