describe Relaton::Bib::ContributorRole do
  before(:each) do
    Relaton::Bib.instance_variable_set :@configuration, nil
  end

  it "raises invalid type argument error" do
    expect { described_class.new type: "type" }.to output(
      /Contributor's type `type` is invalid/,
    ).to_stderr
  end
end
