describe RelatonBib::Element::Media do
  let(:args) do
    { id: "ID", src: "src", filename: "file", alt: "alt", title: "title", longdesc: "desc" }
  end

  describe RelatonBib::Element::Audio do
    let(:audio_args) do
      content = RelatonBib::Element::Altsource.new src: "alt_src", mimetype: "audio/mpeg"
      args.merge(mimetype: "audio/wav", content: [content])
    end
    subject do
      described_class.new(**audio_args)
    end

    it "initialize" do
      expect(subject.id).to eq "ID"
      expect(subject.src).to eq "src"
      expect(subject.mimetype).to eq "audio/wav"
      expect(subject.filename).to eq "file"
      expect(subject.alt).to eq "alt"
      expect(subject.title).to eq "title"
      expect(subject.longdesc).to eq "desc"
      expect(subject.content[0]).to be_instance_of RelatonBib::Element::Altsource
    end

    it "to_xml" do
      doc = Nokogiri::XML::Builder.new { |xml| subject.to_xml xml }.doc.root
      expect(doc.to_xml).to be_equivalent_to <<~XML
        <audio id="ID" src="src" mimetype="audio/wav" filename="file" alt="alt" title="title" longdesc="desc">
          <altsource src="alt_src" mimetype="audio/mpeg"/>
        </audio>
      XML
    end
  end

  describe RelatonBib::Element::Image do
    let(:image_args) { args.merge(mimetype: "image/png", height: "100", width: "200") }

    subject { described_class.new(**image_args) }

    it "initialize" do
      expect(subject.id).to eq "ID"
      expect(subject.src).to eq "src"
      expect(subject.mimetype).to eq "image/png"
      expect(subject.filename).to eq "file"
      expect(subject.height).to eq "100"
      expect(subject.width).to eq "200"
      expect(subject.alt).to eq "alt"
      expect(subject.title).to eq "title"
      expect(subject.longdesc).to eq "desc"
    end

    it "to_xml" do
      doc = Nokogiri::XML::Builder.new { |xml| subject.to_xml xml }.doc.root
      expect(doc.to_xml).to be_equivalent_to <<~XML
        <image id="ID" src="src" mimetype="image/png" filename="file" height="100" width="200" alt="alt" title="title" longdesc="desc"/>
      XML
    end
  end

  describe RelatonBib::Element::Video do
    let(:video_args) do
      content = RelatonBib::Element::Altsource.new src: "alt_src", mimetype: "video/mp4"
      args.merge(mimetype: "video/webm", content: [content])
    end

    subject { described_class.new(**video_args) }

    it "initialize" do
      expect(subject.id).to eq "ID"
      expect(subject.src).to eq "src"
      expect(subject.mimetype).to eq "video/webm"
      expect(subject.filename).to eq "file"
      expect(subject.alt).to eq "alt"
      expect(subject.title).to eq "title"
      expect(subject.longdesc).to eq "desc"
      expect(subject.content[0]).to be_instance_of RelatonBib::Element::Altsource
    end

    it "to_xml" do
      doc = Nokogiri::XML::Builder.new { |xml| subject.to_xml xml }.doc.root
      expect(doc.to_xml).to be_equivalent_to <<~XML
        <video id="ID" src="src" mimetype="video/webm" filename="file" alt="alt" title="title" longdesc="desc">
          <altsource src="alt_src" mimetype="video/mp4"/>
        </video>
      XML
    end
  end
end
