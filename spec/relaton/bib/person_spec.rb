describe Relaton::Bib::Person do
  context Relaton::Bib::FullName do
    xit "rises name error" do
      expect do
        Relaton::Bib::FullName.new
      end.to raise_error ArgumentError
    end
  end

  context Relaton::Bib::Person::Identifier do
    xit "raises type error" do
      expect do
        Relaton::Bib::Person.new(
          name: Relaton::Bib::FullName.new(completename: "John Lennon"),
          identifier: Relaton::Bib::Person::Identifier.new(type: "wrong_type", content: "value"),
        )
      end.to raise_error ArgumentError
    end
  end
end
