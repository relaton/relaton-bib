describe RelatonBib::Address do
  it "raises ArgumentError if either formatted address or city and country are not provided" do
    expect { RelatonBib::Address.new }.to raise_error(ArgumentError)
  end

  context "render formatted address" do
    let(:contrib) { RelatonBib::Address.new(formatted_address: "formatted address") }

    it "as XML" do
      xml = Nokogiri::XML::Builder.new { |b| contrib.to_xml(b) }.doc.root
      formatted_address = xml.xpath("/address/formattedAddress").text
      expect(formatted_address).to eq "formatted address"
    end

    it "as Hash" do
      hash = contrib.to_hash
      expect(hash["address"]["formatted_address"]).to eq "formatted address"
    end

    it "as AsciiBib" do
      expect(contrib.to_asciibib).to eq "address.formatted_address:: formatted address\n"
    end
  end
end

describe RelatonBib::Affiliation do
  let(:org) { RelatonBib::Organization.new(name: "Org") }
  let(:name) { RelatonBib::LocalizedString.new("Name", "en") }
  let(:desc) { RelatonBib::FormattedString.new(content: "Description", language: "en") }
  subject do
    description = desc ? [desc] : []
    described_class.new(organization: org, name: name, description: description)
  end

  context "render affiliation" do
    context "with all fields" do
      it "as XML" do
        xml = Nokogiri::XML::Builder.new { |b| subject.to_xml(builder: b) }.doc.root
        expect(xml.to_s).to be_equivalent_to <<~XML
          <affiliation>
            <name language="en">Name</name>
            <description format="text/plain" language="en">Description</description>
            <organization>
              <name>Org</name>
            </organization>
          </affiliation>
        XML
      end

      it "as Hash" do
        hash = subject.to_hash
        expect(hash["organization"]["name"][0]["content"]).to eq "Org"
        expect(hash["name"]["content"]).to eq "Name"
        expect(hash["name"]["language"]).to eq ["en"]
        expect(hash["description"][0]["content"]).to eq "Description"
        expect(hash["description"][0]["language"]).to eq ["en"]
      end

      it "as AsciiBib" do
        expect(subject.to_asciibib).to eq <<~ASCIIBIB
          affiliation.name.content:: Name
          affiliation.name.language:: en
          affiliation.description.content:: Description
          affiliation.description.language:: en
          affiliation.description.format:: text/plain
          affiliation.organization.name:: Org
        ASCIIBIB
      end
    end

    context "without organization" do
      let(:org) { nil }

      it "as XML" do
        xml = Nokogiri::XML::Builder.new { |b| subject.to_xml(builder: b) }.doc.root
        expect(xml.to_s).to be_equivalent_to <<~XML
          <affiliation>
            <name language="en">Name</name>
            <description format="text/plain" language="en">Description</description>
          </affiliation>
        XML
      end

      it "as Hash" do
        hash = subject.to_hash
        expect(hash).not_to have_key "organization"
      end

      it "as AsciiBib" do
        expect(subject.to_asciibib).not_to include "affiliation.organization"
      end
    end

    context "without name" do
      let(:name) { nil }

      it "as XML" do
        xml = Nokogiri::XML::Builder.new { |b| subject.to_xml(builder: b) }.doc.root
        expect(xml.to_s).to be_equivalent_to <<~XML
          <affiliation>
            <description format="text/plain" language="en">Description</description>
            <organization>
              <name>Org</name>
            </organization>
          </affiliation>
        XML
      end

      it "as Hash" do
        hash = subject.to_hash
        expect(hash).not_to have_key "name"
      end

      it "as AsciiBib" do
        expect(subject.to_asciibib).not_to include "affiliation.name"
      end
    end

    context "without description" do
      let(:desc) { nil }

      it "as XML" do
        xml = Nokogiri::XML::Builder.new { |b| subject.to_xml(builder: b) }.doc.root
        expect(xml.to_s).to be_equivalent_to <<~XML
          <affiliation>
            <name language="en">Name</name>
            <organization>
              <name>Org</name>
            </organization>
          </affiliation>
        XML
      end

      it "as Hash" do
        expect(subject.to_hash).not_to have_key "description"
      end

      it "as AsciiBib" do
        expect(subject.to_asciibib).not_to include "affiliation.description"
      end
    end

    it "without any fields" do
      xml = Nokogiri::XML::Builder.new { |b| described_class.new.to_xml(builder: b) }.doc.root
      expect(xml.to_s).to eq ""
    end
  end

  context "desctiption" do
    it "returns all descriptions if language is not specified" do
      expect(subject.description).to eq [desc]
    end

    it "returns description with specified language" do
      expect(subject.description("en")).to eq [desc]
      expect(subject.description("fr")).to be_empty
    end
  end
end
