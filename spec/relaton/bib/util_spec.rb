describe Relaton::Bib::Util do
  it "#respond_to_missing?" do
    expect(described_class.respond_to?(:warn)).to be true
  end

  it "#method_missing" do
    expect do
      expect(described_class.warn("msg")).to be nil
    end.to output(/\[relaton-bib\] WARN: msg\n/).to_stderr_from_any_process
  end
end
