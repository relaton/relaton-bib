describe Relaton::Bib::ItemData do
  let(:title) do
    [
      Relaton::Bib::Title.new(content: "Main", type: "main", language: "en"),
      Relaton::Bib::Title.new(content: "Title Main", type: "title-main", language: "en"),
      Relaton::Bib::Title.new(content: "Title Intro", type: "title-intro", language: "en"),
      Relaton::Bib::Title.new(content: "Title Part", type: "title-part", language: "en"),
      Relaton::Bib::Title.new(content: "Main", type: "main", language: "fr"),
      Relaton::Bib::Title.new(content: "Title Main", type: "title-main", language: "fr"),
      Relaton::Bib::Title.new(content: "Title Intro", type: "title-intro", language: "fr"),
      Relaton::Bib::Title.new(content: "Title Part", type: "title-part", language: "fr"),
    ]
  end

  let(:structuredidentifier) do
    Relaton::Bib::StructuredIdentifier.new(
      type: "ISO",
      agency: ["ISO"],
      docnumber: "456",
      partnumber: "789",
      edition: "1",
      version: "2",
      supplementtype: "A",
      supplementnumber: "1",
      amendment: "2",
      corrigendum: "3",
    )
  end

  let(:docidentifier) { Relaton::Bib::Docidentifier.new(content: "ISO 123-4:2011", type: "ISO") }
  let(:ext) { Relaton::Bib::Ext.new structuredidentifier: [structuredidentifier] }
  let(:abstract) { Relaton::Bib::LocalizedMarkedUpString.new(content: "Abstract", language: "en") }
  let(:source) do
    Relaton::Bib::Uri.new(type: "src", content: "https://www.iso.org/iso-123-4-2011")
  end
  let(:relation) do
    Relaton::Bib::Relation.new(
      type: "replaces",
      bibitem: Relaton::Bib::ItemData.new(formattedref: "ISO 123-4:2010"),
    )
  end

  subject(:item) do
    described_class.new(
      id: "ISO12342011", title: title, docidentifier: [docidentifier], abstract: [abstract],
      source: [source], language: ["en", "fr"], script: ["Latn"], relation: [relation], ext: ext
    )
  end

  it "#to_all_parts" do
    allow_any_instance_of(Relaton::Bib::Docidentifier).to receive(:to_all_parts!)
    allow_any_instance_of(Relaton::Bib::StructuredIdentifier).to receive(:to_all_parts!)
    ap_item = item.to_all_parts
    expect(ap_item).to be_a Relaton::Bib::ItemData
    expect(ap_item.relation.size).to eq 2
    expect(ap_item.relation[1].type).to eq "instanceOf"
    expect(ap_item.relation[1].bibitem).to be_a Relaton::Bib::ItemData
    expect(ap_item.title.any?(type: "title-part")).to be false
    expect(ap_item.title.size).to eq 6
    expect(ap_item.title.find { |t| t.type == "main" }.content).to eq "Title Main - Title Intro"
    expect(ap_item.abstract.any?).to be false
  end

  it "#to_most_recent_reference" do
    allow_any_instance_of(Relaton::Bib::Docidentifier).to receive(:remove_date!)
    allow_any_instance_of(Relaton::Bib::StructuredIdentifier).to receive(:remove_date!)
    allow_any_instance_of(Relaton::Bib::ItemData).to receive(:create_id).with(without_date: true)
    mrr_item = item.to_most_recent_reference
    expect(mrr_item).to be_a Relaton::Bib::ItemData
    expect(mrr_item.relation.size).to eq 2
    expect(mrr_item.relation[1].type).to eq "instanceOf"
    expect(mrr_item.relation[1].bibitem).to be_a Relaton::Bib::ItemData
    expect(mrr_item.abstract).to be_empty
    expect(mrr_item.date).to be_empty
  end

  context "#create_id" do
    it "raises NotImplementedError" do
      expect { item.create_id }.to raise_error NotImplementedError
    end
  end

  context "#title" do
    it "returns title in specified language" do
      expect(item.title(:en).size).to eq 4
      expect(item.title(:fr).size).to eq 4
    end

    it "returns empty array if language not found" do
      expect(item.title(:de)).to eq []
    end
  end

  context "#abstract" do
    it "returns abstract in specified language" do
      expect(item.abstract(:en).size).to eq 1
      expect(item.abstract(:fr).size).to eq 0
    end

    it "returns empty array if language not found" do
      expect(item.abstract(:de)).to eq []
    end
  end

  context "#source" do
    it "returns source content for specified type" do
      expect(item.source(:src)).to eq "https://www.iso.org/iso-123-4-2011"
    end

    it "returns nil if source type not found" do
      expect(item.source(:other)).to be_nil
    end

    it "returns array of sources if no type specified" do
      expect(item.source).to be_instance_of Array
    end
  end

  context "#relation" do
    it "returns replaces relations" do
      expect(subject.relation(:replaces)).to be_instance_of Array
    end
  end

  context "#to_xml" do
    it "returns bibdata XML" do
      xml = item.to_xml(bibdata: true)
      expect(xml).to include("<bibdata schema-version=")
    end

    it "returns bibitem XML" do
      xml = item.to_xml
      expect(xml).to include("<bibitem id=\"ISO12342011\" schema-version=")
    end

    it "returns XML with notes" do
      xml = item.to_xml note: [{ type: "note", content: "Note 1" }]
      expect(xml).to include('<note type="note">Note 1</note>')
    end
  end
end
