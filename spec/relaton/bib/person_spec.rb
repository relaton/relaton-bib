describe Relaton::Bib::Person do
  context Relaton::Bib::FullName do
    it "rises name error" do
      expect do
        Relaton::Bib::FullName.new
      end.to raise_error ArgumentError
    end
  end

  context Relaton::Bib::PersonIdentifier do
    it "raises type error" do
      expect do
        Relaton::Bib::Person.new(
          name: Relaton::Bib::FullName.new(completename: "John Lennon"),
          identifier: Relaton::Bib::PersonIdentifier.new("wrong_type", "value"),
        )
      end.to raise_error ArgumentError
    end
  end
end
