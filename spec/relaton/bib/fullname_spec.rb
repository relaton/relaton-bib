describe Relaton::Bib::FullName do
  let(:xml) do
    <<~XML
      <name>
        <abbreviation>JD</abbreviation>
        <prefix>Dr</prefix>
        <forename initial="J">John</forename>
        <formatted-initials>J.D.</formatted-initials>
        <surname>Doe</surname>
        <addition>III</addition>
      </name>
    XML
  end

  context "parse XML" do
    it "with name parts" do
      name = described_class.from_xml xml
      expect(name.abbreviation).to be_instance_of Relaton::Bib::FullNameType::Abbreviation
      expect(name.prefix.first).to be_instance_of Relaton::Bib::FullNameType::Prefix
      expect(name.forename.first).to be_instance_of Relaton::Bib::FullNameType::Forename
      expect(name.initials).to be_instance_of Relaton::Bib::FullNameType::FormattedInitials
      expect(name.surname).to be_instance_of Relaton::Bib::FullNameType::Surname
      expect(name.addition.first).to be_instance_of Relaton::Bib::FullNameType::Addition
      expect(described_class.to_xml(name)).to be_equivalent_to xml
    end

    it "with completename" do
      xml = <<~XML
        <name>
          <abbreviation>JD</abbreviation>
          <completename>Dr John Doe III</completename>
        </name>
      XML
      name = described_class.from_xml xml
      expect(name.completename).to be_instance_of Relaton::Bib::FullNameType::Completename
      expect(described_class.to_xml(name)).to be_equivalent_to xml
    end

    it "with note" do
      xml = <<~XML
        <name>
          <surname>Doe</surname>
          <note>some note</note>
        </name>
      XML
      name = described_class.from_xml xml
      expect(name.note.first).to be_instance_of Relaton::Bib::Note
      expect(described_class.to_xml(name)).to be_equivalent_to xml
    end

    it "with variant" do
      xml = <<~XML
        <name>
          <surname>Doe</surname>
          <variant type="nickname">
            <surname>Smith</surname>
          </variant>
        </name>
      XML
      name = described_class.from_xml xml
      expect(name.variant.first).to be_instance_of Relaton::Bib::FullNameType::Variant
      expect(described_class.to_xml(name)).to be_equivalent_to xml
    end
  end
end
