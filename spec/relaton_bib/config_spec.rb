describe RelatonBib::Config do
  it "configure" do
    RelatonBib.configure { |conf| conf.logger = :logger }
    expect(RelatonBib.configuration.logger).to eq :logger
  end
end
