describe Relaton::Model::Contributor do
  context "person" do
    let(:xml) do
      <<~XML
        <contributor>
          <role type="author"/>
          <person><name><completename>John Doe</completename></name></person>
        </contributor>
      XML
    end

    it "parse XML" do
      contrib = described_class.from_xml xml
      expect(contrib.role.first.type).to eq "author"
      expect(contrib.entity).to be_instance_of Relaton::Bib::Person
      expect(contrib.entity.name).to be_instance_of Relaton::Bib::FullName
      expect(contrib.entity.name.completename.content).to eq "John Doe"
    end
  end
end
