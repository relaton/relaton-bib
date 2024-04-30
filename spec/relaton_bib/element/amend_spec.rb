describe RelatonBib::Element::Amend do
  let(:change) { "add" }

  subject do
    location = RelatonBib::Element::AmendType::Location.new(content: [RelatonBib::Locality.new("section", "1")])
    paragraph = RelatonBib::Element::ParagraphWithFootnote.new(content: [RelatonBib::Element::Text.new("paragraph")])
    description = RelatonBib::Element::AmendType::Description.new(content: [paragraph])
    newcontent = RelatonBib::Element::AmendType::Newcontent.new(content: [paragraph])
    tag = RelatonBib::Element::Classification::Tag.new("tag")
    value = RelatonBib::Element::Classification::Value.new("value")
    classification = RelatonBib::Element::Classification.new(tag: tag, value: value)
    organization = RelatonBib::Organization.new(name: "org")
    role_description = RelatonBib::Contributor::Role::Description.new(content: "description")
    role = RelatonBib::Contributor::Role.new(type: "type", description: [role_description])
    contributor = RelatonBib::Contributor.new entity: organization, role: [role]
    described_class.new(
      id: "ID", change: change, path: "path", path_end: "path_end", title: "title",
      location: location, description: description, newcontent: newcontent,
      classification: [classification], contributor: [contributor]
    )
  end

  it "initialize amend" do
    expect(subject.id).to eq "ID"
    expect(subject.change).to eq change
    expect(subject.path).to eq "path"
    expect(subject.path_end).to eq "path_end"
    expect(subject.title).to eq "title"
    expect(subject.location).to be_instance_of RelatonBib::Element::AmendType::Location
    expect(subject.description).to be_instance_of RelatonBib::Element::AmendType::Description
    expect(subject.newcontent).to be_instance_of RelatonBib::Element::AmendType::Newcontent
    expect(subject.classification[0]).to be_instance_of RelatonBib::Element::Classification
    expect(subject.contributor[0]).to be_instance_of RelatonBib::Contributor
  end

  context "warn when invalid change" do
    let(:change) { "invalid" }

    it do
      expect { subject }.to output(/amend\[@change="invalid"\] is invalid/).to_stderr_from_any_process
    end
  end

  it "to_xml" do
    doc = Nokogiri::XML::Builder.new { |b| subject.to_xml b }.doc.root
    expect(doc.to_xml).to be_equivalent_to <<~XML
      <amend id="ID" change="add" path="path" path_end="path_end" title="title">
        <location>
          <locality type="section"><referenceFrom>1</referenceFrom></locality>
        </location>
        <description>
          <p>paragraph</p>
        </description>
        <newcontent>
          <p>paragraph</p>
        </newcontent>
        <classification>
          <tag>tag</tag>
          <value>value</value>
        </classification>
        <contributor>
          <organization>
            <name>org</name>
          </organization>
          <role type="type">
            <description>description</description>
          </role>
        </contributor>
      </amend>
    XML
  end
end
