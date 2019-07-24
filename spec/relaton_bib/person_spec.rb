RSpec.describe RelatonBib::Person do
  context RelatonBib::FullName do
    it "rises name error" do
      expect do
        RelatonBib::FullName.new
      end.to raise_error ArgumentError
    end
  end

  context RelatonBib::PersonIdentifier do
    it "raises type error" do
      expect do
        RelatonBib::Person.new(
          name: RelatonBib::FullName.new(completename: "John Lennon"),
          identifier: RelatonBib::PersonIdentifier.new("wrong_type", "value"),
        )
      end.to raise_error ArgumentError
    end
  end
end
