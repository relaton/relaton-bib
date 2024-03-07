describe RelatonBib::LoggerPool do
  it "initialize" do
    expect(subject.loggers).to eq []
  end

  it "<<" do
    subject << :logger
    expect(subject.loggers).to eq [:logger]
  end

  it "#loggers=" do
    subject.loggers = [:logger]
    expect(subject.loggers).to eq [:logger]
  end

  it "#unknown" do
    logger = double("logger")
    expect(logger).to receive(:unknown).with("progname", key: "val")
    subject << logger
    subject.unknown "progname", key: "val"
  end

  it "#truncate" do
    logger = double("logger")
    expect(logger).to receive(:truncate)
    subject << logger
    subject.truncate
  end
end

describe RelatonBib::Logger do
  subject { described_class.new $stderr }

  context "initialize" do
    it "default" do
      expect(Logger::LogDevice).to receive(:new).with($stderr, shift_age: 0, shift_size: 1048576).and_return :dev

      expect(subject.level).to eq ::Logger::DEBUG
      expect(subject.progname).to be_nil
      expect(subject.datetime_format).to be_nil
      expect(subject.formatter).to be_nil
      expect(subject.instance_variable_get(:@logdev)).to eq :dev
    end

    it "with options" do
      expect(Logger::LogDevice).to receive(:new).with(
        $stderr, shift_age: 1, shift_size: 1024, shift_period_suffix: "%Y-%m-%d", binmode: true
      ).and_return :dev

      l = described_class.new($stderr, 1, 1024, level: ::Logger::INFO, progname: "progname", formatter: :formatter,
                                                datetime_format: "%m/%d/%Y", binmode: true,
                                                shift_period_suffix: "%Y-%m-%d")

      expect(l.level).to eq ::Logger::INFO
      expect(l.progname).to eq "progname"
      expect(l.datetime_format).to eq "%m/%d/%Y"
      expect(l.formatter).to eq :formatter
      expect(l.instance_variable_get(:@logdev)).to eq :dev
    end
  end

  context "instance methods" do
    it "#unknown" do
      expect(subject).to receive(:add).with(::Logger::UNKNOWN, nil, "msg", key: "val").and_return true
      subject.unknown "msg", key: "val"
    end

    it "#fatal" do
      expect(subject).to receive(:add).with(::Logger::FATAL, nil, "msg", key: "val").and_return true
      subject.fatal "msg", key: "val"
    end

    it "#error" do
      expect(subject).to receive(:add).with(::Logger::ERROR, nil, "msg", key: "val").and_return true
      subject.error "msg", key: "val"
    end

    it "#warn" do
      expect(subject).to receive(:add).with(::Logger::WARN, nil, "msg", key: "val").and_return true
      subject.warn "msg", key: "val"
    end

    it "#info" do
      expect(subject).to receive(:add).with(::Logger::INFO, nil, "msg", key: "val").and_return true
      subject.info "msg", key: "val"
    end

    it "#debug" do
      expect(subject).to receive(:add).with(::Logger::DEBUG, nil, "msg", key: "val").and_return true
      subject.debug "msg", key: "val"
    end

    context "#add" do
      context "don't log" do
        before do
          prog = double("progname")
          expect(prog).not_to receive(:nil?)
          subject.progname = prog
        end

        it "no logdev" do
          subject.instance_variable_set :@logdev, nil
          expect(subject.add(::Logger::UNKNOWN, "msg")).to be true
        end

        it "severity < level" do
          subject.level = ::Logger::INFO
          expect(subject.add(::Logger::DEBUG, "msg")).to be true
        end
      end

      it "progname is nil" do
        expect(subject.instance_variable_get(:@logdev)).to receive(:write).with(
          "ANY: msg\n",
        )
        subject.add(::Logger::UNKNOWN, "msg")
      end

      it "progname is not nil" do
        subject.progname = "progname"
        expect(subject.instance_variable_get(:@logdev)).to receive(:write).with(
          "[progname] FATAL: msg\n",
        )
        subject.add(::Logger::FATAL, "msg")
      end

      it "message is nil" do
        expect(subject.instance_variable_get(:@logdev)).to receive(:write).with(
          "ERROR: progname\n",
        )
        subject.add(::Logger::ERROR, nil, "progname")
      end

      it "key given" do
        expect(subject.instance_variable_get(:@logdev)).to receive(:write).with(
          "[progname] WARN: (key) msg\n",
        )
        subject.add(::Logger::WARN, "msg", "progname", key: "key")
      end

      it "block given" do
        expect(subject.instance_variable_get(:@logdev)).to receive(:write).with(
          "[progname] INFO: msg\n",
        )
        subject.add(::Logger::INFO, nil, "progname") { "msg" }
      end
    end

    it "#truncate" do
      dev = double("dev")
      expect(dev).to receive(:truncate)
      subject.instance_variable_set :@logdev, dev
      subject.truncate
    end
  end
end

describe RelatonBib::Logger::FormatterString do
  context "#call" do
    it "no key" do
      expect(subject.call("DEBUG", "datetime", "progname", "msg")).to eq "[progname] DEBUG: msg\n"
    end

    it "key" do
      expect(subject.call("INFO", "datetime", "progname", "msg", key: "key")).to eq "[progname] INFO: (key) msg\n"
    end

    it "no progname" do
      expect(subject.call("WARN", "datetime", nil, "msg")).to eq "WARN: msg\n"
    end
  end
end

describe RelatonBib::Logger::FormatterJSON do
  context "#call" do
    it "no key" do
      expect(subject.call("severity", "datetime", "progname", "msg")).to eq(
        { prog: "progname", message: "msg", severity: "severity" }.to_json
      )
    end

    it "key" do
      expect(subject.call("severity", "datetime", "progname", "msg", key: "key")).to eq(
        { prog: "progname", message: "msg", severity: "severity", key: "key" }.to_json
      )
    end
  end
end

describe RelatonBib::Logger::LogDevice do
  context "#truncate" do
    let(:dev) { double("dev") }

    subject do
      expect(dev).to receive(:respond_to?).with(:write).and_return true
      expect(dev).to receive(:respond_to?).with(:close).and_return true
      expect(dev).to receive(:respond_to?).with(:path).and_return false
      described_class.new dev
    end

    it "respond to truncate" do
      expect(dev).to receive(:respond_to?).with(:truncate).and_return true
      expect(dev).to receive(:truncate)
      expect(dev).to receive(:rewind)
      subject.truncate
    end

    it "not respond to truncate" do
      expect(dev).to receive(:respond_to?).with(:truncate).and_return false
      expect(dev).not_to receive(:truncate)
      subject.truncate
    end
  end
end
