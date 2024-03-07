describe RelatonBib::Config do
  it "configure" do
    RelatonBib.configure do |conf|
      conf.logger_pool = [:logger1]
      conf.logger_pool << :logger2
    end
    expect(RelatonBib.configuration.logger_pool.loggers).to eq %i[logger1 logger2]
  end
end
