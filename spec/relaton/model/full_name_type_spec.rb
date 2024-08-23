describe Relaton::Model::FullNameType do
  let(:fake_class) do
    Class.new(Lutaml::Model::Serializable) do
      include Relaton::Model::FullNameType

      mappings[:xml].instance_eval do
        root "item"
      end
    end
  end

  context "XML mapping" do
    it "with completename" do
      xml = <<~XML
        <item>
          <abbreviation language="en" script="Latn" locale="US">JD</abbreviation>
          <completename language="en" script="Latn" locale="US">John Doe</completename>
          <note language="en" script="Latn" locale="US">Note</note>
        </item>
      XML

      item = fake_class.from_xml xml
      expect(item.abbreviation).to be_instance_of Relaton::Model::FullNameType::Abbreviation
      expect(item.completename).to be_instance_of Relaton::Model::FullNameType::Completename
      expect(item.note).to be_instance_of Array
      expect(item.note.size).to eq 1
      expect(item.note.first).to be_instance_of Relaton::Bib::BiblioNote
      expect(item.to_xml).to be_equivalent_to xml
    end

    it "with name parts" do
      xml = <<~XML
        <item>
          <prefix language="en" script="Latn" locale="US">Dr</prefix>
          <forename initial="J" language="en" script="Latn" locale="US">John</forename>
          <formatted-initials language="en" script="Latn" locale="US">J D</formatted-initials>
          <surname language="en" script="Latn" locale="US">Doe</surname>
          <addition language="en" script="Latn" locale="US">Jr</addition>
        </item>
      XML

      item = fake_class.from_xml xml
      expect(item.prefix).to be_instance_of Array
      expect(item.prefix.size).to eq 1
      expect(item.prefix.first).to be_instance_of Relaton::Model::FullNameType::Prefix
      expect(item.forename).to be_instance_of Array
      expect(item.forename.size).to eq 1
      expect(item.forename.first).to be_instance_of Relaton::Model::FullNameType::Forename
      expect(item.formatted_initials).to be_instance_of Relaton::Model::FullNameType::FormattedInitials
      expect(item.surname).to be_instance_of Relaton::Model::FullNameType::Surname
      expect(item.addition).to be_instance_of Array
      expect(item.to_xml).to be_equivalent_to xml
    end

    it "with variants" do
      xml = <<~XML
        <item>
          <variant type="variant">
            <completename>John Doe</completename>
          </variant>
        </item>
      XML
      item = fake_class.from_xml xml
      expect(item.variant).to be_instance_of Array
      expect(item.variant.size).to eq 1
      expect(item.variant.first).to be_instance_of Relaton::Model::FullNameType::Variant
      expect(item.to_xml).to be_equivalent_to xml
    end
  end
end
