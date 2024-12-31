describe Relaton::Bib::Contributor::Role do
  # before(:each) { Relaton::Bib.instance_variable_set :@configuration, nil }

  it "raises invalid type argument error" do
    expect { described_class.new type: "type" }.to output(
      /Contributor's type `type` is invalid/,
    ).to_stderr
  end
end
