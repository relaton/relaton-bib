describe Relaton::Bib::RelationCollection do
  context "instance" do
    subject do
      described_class.new(
        [
          Relaton::Bib::Relation.new(
            type: "replace",
            bibitem: Relaton::Bib::Item.new(
              formattedref: Relaton::Bib::Formattedref.new(content: "realtion1"),
            ),
          ),
          Relaton::Bib::Relation.new(
            type: "obsoletes", bibitem: "realtion1",
          ),
        ],
      )
    end

    it "returns one replace" do
      expect(subject.replaces.size).to eq 1
    end

    it "#select" do
      expect(subject.select { |r| r.type == "replace" }.size).to eq 1 # @TODO use count instead of select and size
    end
  end
end
