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

  subject(:item) do
    described_class.new(title: title, docidentifier: [docidentifier], abstract: [abstract],
                        language: ["en", "fr"], script: ["Latn"], ext: ext)
  end

  it "#to_all_parts" do
    allow_any_instance_of(Relaton::Bib::Docidentifier).to receive(:to_all_parts)
    allow_any_instance_of(Relaton::Bib::StructuredIdentifier).to receive(:to_all_parts)
    ap_item = item.to_all_parts
    expect(ap_item).to be_a Relaton::Bib::ItemData
    expect(ap_item.relation.size).to eq 1
    expect(ap_item.relation.first.type).to eq "instanceOf"
    expect(ap_item.relation.first.bibitem).to be_a Relaton::Bib::ItemData
    expect(ap_item.title.any?(type: "title-part")).to be false
    expect(ap_item.title.size).to eq 6
    expect(ap_item.title.find { |t| t.type == "main" }.content).to eq "Title Main - Title Intro"
    expect(ap_item.abstract.any?).to be false
  end
end
