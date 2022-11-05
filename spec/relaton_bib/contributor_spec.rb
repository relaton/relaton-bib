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
