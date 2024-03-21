describe RelatonBib::Config do
  it "configure" do
    RelatonBib.configure do |conf|
      expect(conf).to be_instance_of RelatonBib::Configuration
    end
  end
end
