describe Relaton::Bib::Docidentifier do
  it "raise NotImplementedError" do
    expect { described_class.new.remove_part }.to raise_error NotImplementedError
    expect { described_class.new.to_all_parts }.to raise_error NotImplementedError
    expect { described_class.new.remove_date }.to raise_error NotImplementedError
  end
end
