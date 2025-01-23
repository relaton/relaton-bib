describe Relaton::Bib::Locality do
  xit "warn if locality type is invalid" do
    expect do
      xml = <<~XML
        <locality type="type" referenceFrom="from"/>
      XML
      loc = Relaton::Model::Locality.from_xml xml
      # Relaton::Bib::BibItemLocality.new type: "type", reference_from: "from"
      Relaton::Model::Locality.to_xml loc
    end.to output(/Invalid locality type/).to_stderr_from_any_process
  end
end
