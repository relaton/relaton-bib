describe Relaton::Model::Contributor do
  context "person" do
    let(:xml) do
      <<~XML
        <contributor>
          <role type="author"/>
          <person><fullname>John Doe</fullname></person>
        </contributor>
      XML
    end

    it "parse XML" do
      contrib = described_class.from_xml xml
      expect(contrib.role.first.type).to eq "author"
      expect(contrib.content).to be_instance_of Relaton::Model::ContributionInfo
      expect(contrib.content.person.fullname.content).to eq "John Doe"
    end
  end
end
