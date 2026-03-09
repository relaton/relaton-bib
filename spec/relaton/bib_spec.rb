describe Relaton::Bib do
  it "has a version number" do
    expect(Relaton::Bib::VERSION).not_to be nil
  end

  it "returns grammar hash" do
    hash = Relaton::Bib.grammar_hash
    expect(hash).to be_instance_of String
    expect(hash.size).to eq 32
  end
end
