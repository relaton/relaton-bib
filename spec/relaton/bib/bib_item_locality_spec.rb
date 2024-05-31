describe Relaton::Bib::BibItemLocality do
  it "warn if locality type is invalid" do
    expect do
      RelatonBib::BibItemLocality.new "type", "from"
    end.to output(/Invalid locality type/).to_stderr_from_any_process
  end
end
