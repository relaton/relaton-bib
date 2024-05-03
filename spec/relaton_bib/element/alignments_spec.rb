describe RelatonBib::Element::Alignments do
  subject { Class.new.include(described_class).new }

  context "check alignment" do
    it "valid alignment" do
      expect { subject.check_alignment("left") }.not_to output.to_stdout
    end

    it "invalid alignment" do
      expect { subject.check_alignment("invalid") }.to output(
        /Invalid alignment: `invalid`/,
      ).to_stderr_from_any_process
    end
  end
end

describe RelatonBib::Element::Valignments do
  subject { Class.new.include(described_class).new }

  context "check valignment" do
    it "valid valignment" do
      expect { subject.check_valignment("top") }.not_to output.to_stdout
    end

    it "invalid valignment" do
      expect { subject.check_valignment("invalid") }.to output(
        /Invalid alignment: `invalid`/,
      ).to_stderr_from_any_process
    end
  end
end
