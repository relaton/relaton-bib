describe Relaton::Bib::DocumentRelation do
  before(:each) { Relaton::Bib.instance_variable_set :@configuration, nil }

  it "warn when type is invalid" do
    expect do
      described_class.new type: "invalid", bibitem: nil
    end.to output(/invalid relation type/).to_stderr
  end
end
