describe RelatonBib::Element::Image do
  subject do
    described_class.new(
      id: "id",
      src: "src",
      mimetype: "mime type",
      filename: "file name",
      width: "60%",
      height: "40%",
      alt: "Alt",
      title: "Title",
      longdesc: "long description",
    )
  end

  it "initialize" do
    expect(subject.id).to eq "id"
    expect(subject.src).to eq "src"
    expect(subject.mimetype).to eq "mime type"
    expect(subject.filename).to eq "file name"
    expect(subject.width).to eq "60%"
    expect(subject.height).to eq "40%"
    expect(subject.alt).to eq "Alt"
    expect(subject.title).to eq "Title"
    expect(subject.longdesc).to eq "long description"
  end

  it "to_xml" do
    builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
      subject.to_xml xml
    end
    xml = builder.doc.root.to_xml
    expect(xml).to be_equivalent_to <<~XML
      <image id="id" src="src" mimetype="mime type" filename="file name" width="60%" height="40%" alt="Alt" title="Title" longdesc="long description"/>
    XML
  end

  it "to_s" do
    expect(subject.to_s).to eq(
      "<image id=\"id\" src=\"src\" mimetype=\"mime type\" filename=\"file name\" width=\"60%\" " \
      "height=\"40%\" alt=\"Alt\" title=\"Title\" longdesc=\"long description\"/>"
    )
  end

  it "to_hash" do
    expect(subject.to_hash).to eq(
      "image" => {
        "id" => "id",
        "src" => "src",
        "mimetype" => "mime type",
        "filename" => "file name",
        "width" => "60%",
        "height" => "40%",
        "alt" => "Alt",
        "title" => "Title",
        "longdesc" => "long description",
      },
    )
  end

  it "to_asciibib" do
    expect(subject.to_asciibib).to eq <<~BIB
      image.id:: id
      image.src:: src
      image.mimetype:: mime type
      image.filename:: file name
      image.width:: 60%
      image.height:: 40%
      image.alt:: Alt
      image.title:: Title
      image.longdesc:: long description
    BIB
  end
end
