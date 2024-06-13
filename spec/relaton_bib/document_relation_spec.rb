RSpec.describe RelatonBib::DocumentRelation do
  before(:each) { RelatonBib.instance_variable_set :@configuration, nil }

  it "warn when type is invalid" do
    expect do
      RelatonBib::DocumentRelation.new type: "invalid", bibitem: nil
    end.to output(/invalid relation type/).to_stderr_from_any_process
  end
end
