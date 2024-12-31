describe Relaton::Bib::Locality do
  xit "warn if locality type is invalid" do
    expect do
      Relaton::Bib::BibItemLocality.new type: "type", reference_from: "from"
    end.to output(/Invalid locality type/).to_stderr_from_any_process
  end
end
