describe Relaton::Bib::Config do
  it "configure" do
    Relaton::Bib.configure { |conf| conf.logger = :logger }
    expect(Relaton::Bib.configuration.logger).to eq :logger
  end
end
