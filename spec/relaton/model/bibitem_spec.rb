describe Relaton::Model::Bibitem do
  let(:xml) do
    <<~XML
      <bibitem id="ID" type="standard" schema-version="1.2.3" fetched="2024-02-01">
        <formattedref><strong>Ref</strong>eren<em>ce</em></formattedref>
        <title type="main" language="en"><em>Main</em> Title</title>
        <title type="subtitle" language="en">Subtitle</title>
        <uri type="src">http://example.com</uri>
        <docidentifier type="ISO">ISO 123</docidentifier>
        <docnumber>123</docnumber>
        <date type="published"><on>2020-01-01</on></date>
        <date type="accessed"><from>2024-02-01</from><to>2024-12-31</to></date>
      </bibitem>
    XML
  end

  context "parse XML" do
    let(:doc) { described_class.from_xml xml }

    it { expect(doc.id).to eq "ID" }
    it { expect(doc.type).to eq "standard" }
    it { expect(doc.schema_version).to eq "1.2.3" }
    it { expect(doc.fetched).to eq Date.new 2024, 2, 1 }
    it { expect(doc.formattedref).to be_instance_of Relaton::Bib::Formattedref }

    it "title" do
      expect(doc.title).to be_instance_of Relaton::Bib::TitleCollection
      expect(doc.title.size).to eq 2
      expect(doc.title.first).to be_instance_of Relaton::Bib::Title
      expect(doc.title[0].content).to be_instance_of Relaton::Model::LocalizedMarkedUpString::Content
      expect(doc.title[0].type).to eq "main"
      expect(doc.title[0].language).to eq "en"
      expect(doc.title[1].content).to be_instance_of Relaton::Model::LocalizedMarkedUpString::Content
      expect(doc.title[1].type).to eq "subtitle"
      expect(doc.title[1].language).to eq "en"
    end

    it "source" do
      expect(doc.source).to be_instance_of Array
      expect(doc.source.size).to eq 1
      expect(doc.source.first).to be_instance_of Relaton::Bib::Bsource
      expect(doc.source.first.content).to be_instance_of Addressable::URI
      expect(doc.source.first.content.to_s).to eq "http://example.com"
      expect(doc.source.first.type).to eq "src"
    end

    it "docidentifier" do
      expect(doc.docidentifier).to be_instance_of Array
      expect(doc.docidentifier.size).to eq 1
      expect(doc.docidentifier.first).to be_instance_of Relaton::Bib::Docidentifier
      expect(doc.docidentifier.first.content).to be_instance_of Relaton::Model::LocalizedMarkedUpString::Content
      expect(doc.docidentifier.first.id).to eq "ISO 123"
      expect(doc.docidentifier.first.type).to eq "ISO"
      expect(doc.docnumber).to eq "123"
    end

    it "date" do
      expect(doc.date).to be_instance_of Array
      expect(doc.date.size).to eq 2
      expect(doc.date.first).to be_instance_of Relaton::Bib::Bdate
      expect(doc.date.first.type).to eq "published"
      expect(doc.date.first.on).to eq "2020-01-01"
      expect(doc.date.last.type).to eq "accessed"
      expect(doc.date.last.from).to eq "2024-02-01"
      expect(doc.date.last.to).to eq "2024-12-31"
    end
  end

  it "to XML" do
    item = Relaton::Bib::Item.new id: "ID", type: "standard", schema_version: "1.2.3", docnumber: "123"
    item.fetched = Date.new 2024, 2, 1
    item.formattedref = Relaton::Bib::Formattedref.new "<strong>Ref</strong>eren<em>ce</em>"
    title = Relaton::Bib::Title.new type: "main", content: "<em>Main</em> Title", language: "en"
    item.title << title
    title = Relaton::Bib::Title.new type: "subtitle", content: "Subtitle", language: "en"
    item.title << title
    item.source << Relaton::Bib::Bsource.new(type: "src", content: "http://example.com")
    item.docidentifier << Relaton::Bib::Docidentifier.new(id: "ISO 123", type: "ISO")
    item.date << Relaton::Bib::Bdate.new(type: "published", on: "2020-01-01")
    item.date << Relaton::Bib::Bdate.new(type: "accessed", from: "2024-02-01", to: "2024-12-31")
    expect(described_class.to_xml(item)).to be_equivalent_to xml
  end
end
