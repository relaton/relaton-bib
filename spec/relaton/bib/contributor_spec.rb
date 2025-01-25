describe Relaton::Bib::Address do
  xit "raises ArgumentError if either formatted address or city and country are not provided" do
    expect { described_class.new }.to raise_error(ArgumentError)
  end

  context "==" do
    it "same content" do
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
    let(:address) { described_class.new(formatted_address: "formatted address") }

    it "as XML" do
      xml = Relaton::Model::Address.to_xml address
      expect(xml).to be_equivalent_to <<~XML
        <address>
          <formattedAddress>formatted address</formattedAddress>
        </address>
      XML
    end

    xit "as Hash" do
      hash = address.to_hash
      expect(hash["address"]["formatted_address"]).to eq "formatted address"
    end

    it "as AsciiBib" do
      expect(address.to_asciibib).to eq "address.formatted_address:: formatted address\n"
    end
  end

  context "render address" do
    let(:address) do
      described_class.new(
        street: ["street1", "street2"],
        city: "city",
        state: "state",
        country: "country",
        postcode: "postcode",
      )
    end

    it "as XML" do
      xml = Relaton::Model::Address.to_xml address
      expect(xml).to be_equivalent_to <<~XML
        <address>
          <street>street1</street>
          <street>street2</street>
          <city>city</city>
          <state>state</state>
          <country>country</country>
          <postcode>postcode</postcode>
        </address>
      XML
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
      expect(address.to_asciibib).to eq <<~ASCIIBIB
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
  let(:orgname) { Relaton::Bib::TypedLocalizedString.new(content: "Org") }
  let(:org) { Relaton::Bib::Organization.new(name: [orgname]) }
  let(:name) { Relaton::Bib::LocalizedString.new(content: "Name", language: "en") }
  let(:desc) { Relaton::Bib::LocalizedString.new(content: "Description", language: "en") }
  subject do
    description = desc ? [desc] : []
    described_class.new(organization: org, name: name, description: description)
  end

  context "==" do
    it "same content" do
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
      it "as XML" do
        xml = Relaton::Model::Affiliation.to_xml subject
        expect(xml).to be_equivalent_to <<~XML
          <affiliation>
            <name language="en">Name</name>
            <description language="en">Description</description>
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

      it "as AsciiBib" do
        expect(subject.to_asciibib).to eq <<~ASCIIBIB
          affiliation.name.content:: Name
          affiliation.name.language:: en
          affiliation.description.content:: Description
          affiliation.description.language:: en
          affiliation.organization.name:: Org
        ASCIIBIB
      end
    end

    context "without organization" do
      let(:org) { nil }

      it "as XML" do
        xml = Relaton::Model::Affiliation.to_xml subject
        expect(xml).to be_equivalent_to <<~XML
          <affiliation>
            <name language="en">Name</name>
            <description language="en">Description</description>
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

      it "as XML" do
        xml = Relaton::Model::Affiliation.to_xml subject
        expect(xml).to be_equivalent_to <<~XML
          <affiliation>
            <description language="en">Description</description>
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

      it "as AsciiBib" do
        expect(subject.to_asciibib).not_to include "affiliation.name"
      end
    end

    context "without description" do
      let(:desc) { nil }

      it "as XML" do
        xml = Relaton::Model::Affiliation.to_xml subject
        expect(xml).to be_equivalent_to <<~XML
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

      it "as AsciiBib" do
        expect(subject.to_asciibib).not_to include "affiliation.description"
      end
    end

    xit "without any fields" do
      xml = Relaton::Model::Affiliation.to_xml described_class.new
      expect(xml).to eq ""
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
