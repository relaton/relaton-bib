describe Relaton::Bib::FullName do
  context "using name parts" do
    subject do
      described_class.new(
        surname: Relaton::Bib::LocalizedString.new(content: "Doe"),
        abbreviation: Relaton::Bib::LocalizedString.new(content: "DJ"),
        forename: [Relaton::Bib::Forename.new(content: "John", initial: "J")],
        initials: Relaton::Bib::LocalizedString.new(content: "J.D."),
        addition: [Relaton::Bib::LocalizedString.new(content: "Jr.")],
        prefix: [Relaton::Bib::LocalizedString.new(content: "Dr.")],
      )
    end

    context "==" do
      xit "same content" do
        other = described_class.new(
          surname: Relaton::Bib::LocalizedString.new(content: "Doe"),
          abbreviation: Relaton::Bib::LocalizedString.new(content: "DJ"),
          forename: [Relaton::Bib::Forename.new(content: "John", initial: "J")],
          initials: Relaton::Bib::LocalizedString.new(content: "J.D."),
          addition: [Relaton::Bib::LocalizedString.new(content: "Jr.")],
          prefix: [Relaton::Bib::LocalizedString.new(content: "Dr.")],
        )
        expect(subject).to eq other
      end

      it "different content" do
        other = described_class.new(
          surname: Relaton::Bib::LocalizedString.new(content: "Doe"),
          abbreviation: Relaton::Bib::LocalizedString.new(content: "DJ"),
          forename: [Relaton::Bib::Forename.new(content: "John", initial: "J")],
          initials: Relaton::Bib::LocalizedString.new(content: "J.D."),
          prefix: [Relaton::Bib::LocalizedString.new(content: "Dr.")],
        )
        expect(subject).not_to eq other
      end
    end

    xit "to_xml" do
      builder = Nokogiri::XML::Builder.new
      subject.to_xml(builder: builder)
      expect(builder.to_xml).to be_equivalent_to <<~XML
        <name>
          <abbreviation>DJ</abbreviation>
          <prefix>Dr.</prefix>
          <forename initial="J">John</forename>
          <formatted-initials>J.D.</formatted-initials>
          <surname>Doe</surname>
          <addition>Jr.</addition>
        </name>
      XML
    end

    xit "to_hash" do
      expect(subject.to_hash).to eq(
        "abbreviation" => { "content" => "DJ" },
        "given" => {
          "forename" => [{ "content" => "John", "initial" => "J" }],
          "formatted_initials" => { "content" => "J.D." },
        },
        "surname" => { "content" => "Doe" },
        "addition" => [{ "content" => "Jr." }],
        "prefix" => [{ "content" => "Dr." }],
      )
    end

    xit "to_asciibib" do
      expect(subject.to_asciibib("name")).to eq <<~ASCIIBIB
        name.name.abbreviation:: DJ
        name.given.forename:: John
        name.given.forename.initial:: J
        name.given.formatted-initials:: J.D.
        name.name.surname:: Doe
        name.name.addition:: Jr.
        name.name.prefix:: Dr.
      ASCIIBIB
    end
  end

  context "using completename" do
    subject do
      described_class.new(
        completename: Relaton::Bib::LocalizedString.new(content: "John Doe"),
      )
    end

    context "==" do
      xit "same content" do
        other = described_class.new(
          completename: Relaton::Bib::LocalizedString.new(content: "John Doe"),
        )
        expect(subject).to eq other
      end

      it "different content" do
        other = described_class.new(
          completename: Relaton::Bib::LocalizedString.new(content: "Jane Doe"),
        )
        expect(subject).not_to eq other
      end
    end

    xit "to_xml" do
      builder = Nokogiri::XML::Builder.new
      subject.to_xml(builder: builder, lang: "en")
      expect(builder.to_xml).to be_equivalent_to <<~XML
        <name>
          <completename>John Doe</completename>
        </name>
      XML
    end

    xit "to_hash" do
      expect(subject.to_hash).to eq(
        "completename" => { "content" => "John Doe" },
      )
    end

    it "to_asciibib" do
      expect(subject.to_asciibib("name")).to eq <<~ASCIIBIB
        name.name.completename:: John Doe
      ASCIIBIB
    end
  end

  xit "raise ArgumentError" do
    expect do
      described_class.new
    end.to raise_error ArgumentError, "Should be given :surname or :completename"
  end
end
