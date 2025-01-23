describe Relaton::Bib::Address do
  xit "raises ArgumentError if either formatted address or city and country are not provided" do
    expect { described_class.new }.to raise_error(ArgumentError)
  end

  context "==" do
    xit "same content" do
      contrib = described_class.new(formatted_address: "formatted address")
      other = described_class.new(formatted_address: "formatted address")
      expect(contrib).to eq other
    end

    it "different content" do
      contrib = described_class.new(formatted_address: "formatted address")
      other = described_class.new(formatted_address: "other formatted address")
      expect(contrib).not_to eq other
    end
  end

  context "render formatted address" do
    let(:contrib) { described_class.new(formatted_address: "formatted address") }

    xit "as XML" do
      xml = Nokogiri::XML::Builder.new { |b| contrib.to_xml(b) }.doc.root
      formatted_address = xml.xpath("/address/formattedAddress").text
      expect(formatted_address).to eq "formatted address"
    end

    xit "as Hash" do
      hash = contrib.to_hash
      expect(hash["address"]["formatted_address"]).to eq "formatted address"
    end

    it "as AsciiBib" do
      expect(contrib.to_asciibib).to eq "address.formatted_address:: formatted address\n"
    end
  end

  context "render address" do
    let(:contrib) do
      described_class.new(
        street: ["street1", "street2"],
        city: "city",
        state: "state",
        country: "country",
        postcode: "postcode",
      )
    end

    xit "as XML" do
      xml = Nokogiri::XML::Builder.new { |b| contrib.to_xml(b) }.doc.root
      street = xml.xpath("/address/street").map(&:text)
      expect(street).to eq %w[street1 street2]
      expect(xml.xpath("/address/city").text).to eq "city"
      expect(xml.xpath("/address/state").text).to eq "state"
      expect(xml.xpath("/address/country").text).to eq "country"
      expect(xml.xpath("/address/postcode").text).to eq "postcode"
    end

    xit "as Hash" do
      hash = contrib.to_hash
      expect(hash["address"]["street"]).to eq %w[street1 street2]
      expect(hash["address"]["city"]).to eq "city"
      expect(hash["address"]["state"]).to eq "state"
      expect(hash["address"]["country"]).to eq "country"
      expect(hash["address"]["postcode"]).to eq "postcode"
    end

    it "as AsciiBib" do
      expect(contrib.to_asciibib).to eq <<~ASCIIBIB
        address.street:: street1
        address.street:: street2
        address.city:: city
        address.state:: state
        address.country:: country
        address.postcode:: postcode
      ASCIIBIB
    end
  end
end

describe Relaton::Bib::Affiliation do
  let(:org) { Relaton::Bib::Organization.new(name: "Org") }
  let(:name) { Relaton::Bib::LocalizedString.new(content: "Name", language: "en") }
  let(:desc) { Relaton::Bib::FormattedString.new(content: "Description", language: "en") }
  subject do
    description = desc ? [desc] : []
    described_class.new(organization: org, name: name, description: description)
  end

  context "==" do
    xit "same content" do
      other = described_class.new(organization: org, name: name, description: [desc])
      expect(subject).to eq other
    end

    it "different content" do
      name = Relaton::Bib::LocalizedString.new(content: "Other", language: "en")
      other = described_class.new(organization: org, name: name, description: [desc])
      expect(subject).not_to eq other
    end
  end

  context "render affiliation" do
    context "with all fields" do
      xit "as XML" do
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

      xit "as Hash" do
        hash = subject.to_hash
        expect(hash["organization"]["name"][0]["content"]).to eq "Org"
        expect(hash["name"]["content"]).to eq "Name"
        expect(hash["name"]["language"]).to eq ["en"]
        expect(hash["description"][0]["content"]).to eq "Description"
        expect(hash["description"][0]["language"]).to eq ["en"]
      end

      xit "as AsciiBib" do
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

      xit "as XML" do
        xml = Nokogiri::XML::Builder.new { |b| subject.to_xml(builder: b) }.doc.root
        expect(xml.to_s).to be_equivalent_to <<~XML
          <affiliation>
            <name language="en">Name</name>
            <description format="text/plain" language="en">Description</description>
          </affiliation>
        XML
      end

      xit "as Hash" do
        hash = subject.to_hash
        expect(hash).not_to have_key "organization"
      end

      it "as AsciiBib" do
        expect(subject.to_asciibib).not_to include "affiliation.organization"
      end
    end

    context "without name" do
      let(:name) { nil }

      xit "as XML" do
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

      xit "as Hash" do
        hash = subject.to_hash
        expect(hash).not_to have_key "name"
      end

      xit "as AsciiBib" do
        expect(subject.to_asciibib).not_to include "affiliation.name"
      end
    end

    context "without description" do
      let(:desc) { nil }

      xit "as XML" do
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

      xit "as Hash" do
        expect(subject.to_hash).not_to have_key "description"
      end

      xit "as AsciiBib" do
        expect(subject.to_asciibib).not_to include "affiliation.description"
      end
    end

    xit "without any fields" do
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
